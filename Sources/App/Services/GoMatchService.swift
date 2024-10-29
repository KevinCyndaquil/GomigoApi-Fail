//
//  MatchService.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 25/10/24.
//

import Vapor
import Fluent
import MongoKitten

let maxDistanceFromCurrent: Double = 20

struct GoMatchService {
    let mongodb: MongoDatabase
    let db: any Database
    
    let userService: UserService
    
    init(on: any Database) throws {
        self.mongodb = try MongoController.client(db: on)
        self.db = on
        self.userService = try UserService(database: on)
    }
    
    func select(id: UUID) async throws -> GoMatch {
        guard let match = try? await GoMatch.query(on: db)
            .filter(\.$id == id)
            .first() else {
            throw Abort(.badRequest, reason: "id de match no encontrado")
        }
        return match
    }
    
    func generate(with matchPostable: GoMatchPostable) async throws -> GoMatch {
        let leader = try await userService.select(id: matchPostable.leader.userFindingMatches.id)
        leader.currentUbication = matchPostable.leader.currentUbication
        
        let match = matchPostable.toModel()
        
        try await leader.update(on: db)
        try await match.save(on: db)
        return match
    }
    
    func filter(matchable: GoUserMatchable) async throws -> [GoMatch] {
        let requester = try await userService.select(id: matchable.userFindingMatches.id)
        
        guard var filteredMatches = try? await GoMatch.query(on: db)
            .sort(\.$status, .ascending)
            .filter(\.$status == .processing)
            .filter(\.$groupLength == matchable.groupLength)
            .filter(\.$id != matchable.matchId.id)
            .all() else {
            throw Abort(.internalServerError, reason: "Error al buscar matches")
        }
        
        print("Match encontrado ", filteredMatches.count)
        
        filteredMatches = filteredMatches.filter ({
            $0.destination.distance(to: matchable.destination) <= maxDistanceFromCurrent
        })
        
        var nearbyMatches: [GoMatch] = []
        
        for match in filteredMatches {
            let members = try await defineMembers(match: match)
            
            if !GoMatch.preferencesMatching(requester: requester, members: members) {
                continue
            }
            
            if (GoMatch.nearest(from: matchable, to: members)) {
                nearbyMatches.append(match)
            }
        }
        return nearbyMatches
    }
    
    func add(from match: GoMatch, requester: MongoRef) async throws -> GoMatch {
        try match.mustActive()
        if let found = try? await GoUser.find(requester.id, on: db) == nil {
            throw Abort(.badRequest, reason: "Requester no se encuentra registrado")
        }
        
        let (inserted, _) = match.requests.insert(requester)
        if !inserted {
            throw Abort(.badRequest, reason: "Usuario ya ha pedido unirse al grupo")
        }
    
        try await match.update(on: db)
        return match
    }
    
    func accept(from match: GoMatch, responser: MongoRef, requester: MongoRef) async throws -> GoMatch {
        try match.mustActive()
        
        if match.leader != responser {
            throw Abort(.badRequest, reason: "Solo el alfitrion del grupo puede aceptar peticiones de otros usuarios")
        }
        let req = try await userService.select(id: requester.id)
        let members = try await defineMembers(match: match)
        
        if !GoMatch.preferencesMatching(requester: req, members: members) {
            match.requests.remove(requester)
            try await match.update(on: db)
            
            throw Abort(.conflict, reason: "El grupo ya no entra dentro de las preferencias del requester")
        }
        
        if match.requests.remove(requester) == nil {
            throw Abort(.badRequest, reason: "Intentas aceptar una peticion de un usuario que no ha hecho ninguna request")
        }
        
        let (inserted, _) = match.members.insert(requester)
        if !inserted {
            throw Abort(.badRequest, reason: "Request aceptada ya se encontraba como miembro")
        }
        if match.members.count + 1 == match.groupLength {
            match.status = .matched
            match.requests = []
        } else {
            let requests = try await defineRequests(match: match)
            
            match.requests = Set(GoMatch.depureRequest(members: members, requests: requests)
                .map { MongoRef(id: $0.id!) })
        }
        
        try await match.update(on: db)
        return match
    }
    
    func decline(leader: MongoRef?, from match: GoMatch, requester: MongoRef) async throws -> GoMatch {
        try match.mustActive()
        
        if (match.leader != leader || !match.requests.contains(requester)) {
            throw Abort(.badRequest, reason: "Solo el alfitrion del grupo o quien realizo el request puede declinar una petición")
        }
        
        if match.requests.remove(requester) == nil {
            throw Abort(.badRequest, reason: "Intentas declinar una peticion de un usuario que no ha hecho ninguna request")
        }
        
        let members = try await defineMembers(match: match)
        let requests = try await defineRequests(match: match)
        
        match.requests = Set(GoMatch.depureRequest(members: members, requests: requests)
            .map { MongoRef(id: $0.id!) })
        
        try await match.update(on: db)
        return match
    }
    
    func wasAccepted(match: GoMatch, requester: MongoRef) throws -> GoMatch {
        if match.members.contains(requester) {
            return match
        }
        if match.requests.contains(requester) {
            throw Abort(.accepted, reason: "El alfitrion del grupo aún sigue verificando tu información")
        }
        throw Abort(.conflict, reason: "El alfitrion del grupo cancelo tu solicitud o el grupo ya no cumplica con tus preferencias")
    }
    
    private func defineMembers(match: GoMatch) async throws -> [GoUser] {
        let leader = try await userService.select(id: match.leader.id)
        
        var userMembers: [GoUser] = [leader]
        for member in match.members {
            let user = try await userService.select(id: member.id)
            userMembers.append(user)
        }
        return userMembers
    }
    
    private func defineRequests(match: GoMatch) async throws -> [GoUser] {
        var requests: [GoUser] = []
        for request in match.requests {
            let requester = try await userService.select(id: request.id)
            requests.append(requester)
        }
        return requests
    }
}
