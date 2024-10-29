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
    
    let userService: GoUserService
    
    init(on: any Database) throws {
        self.mongodb = try MongoController.client(db: on)
        self.db = on
        self.userService = try GoUserService(on: on)
    }
    
    func select(id: UUID) async throws -> GoMatch {
        guard let match = try? await GoMatch.query(on: db)
            .filter(\.$id == id)
            .first() else {
            throw Abort(.badRequest, reason: "id de match no encontrado")
        }
        return match
    }
    
    func generate(with matchable: GoUserMatchable) async throws -> GoMatch {
        let leader = try await userService.select(id: matchable.userFindingMatches.id)
        leader.currentUbication = matchable.currentUbication
        
        let match = matchable.toModel()
        
        try await leader.update(on: db)
        try await match.save(on: db)
        return match
    }
    
    func filter(matchable: GoUserMatchable) async throws -> [GoMatch] {
        let requester = try await userService.select(id: matchable.userFindingMatches.id)
        
        guard var filteredMatches = try? await GoMatch.query(on: db)
            .filter(\.$status == .processing)
            .filter(\.$transport == matchable.transport)
            .filter(\.$groupLength == matchable.groupLength)
            .filter(\.$id != matchable.matchId?.id ?? UUID())
            .sort(\.$status, .ascending)
            .all() else {
            throw Abort(.internalServerError, reason: "Error al buscar matches")
        }
        
        print("Matches encontrado ", filteredMatches.count)
        
        filteredMatches = filteredMatches.filter ({
            $0.destination.distance(to: matchable.destination) <= maxDistanceFromCurrent
        })
        
        print("Matches encontrados despues de filtrar por distancia ", filteredMatches.count)
        
        var nearbyMatches: [GoMatch] = []
        
        for match in filteredMatches {
            let members = try await defineMembers(match: match)
            
            print(GoMatch.preferencesMatching(requester: requester, members: members))
            
            if !GoMatch.preferencesMatching(requester: requester, members: members) {
                continue
            }
            
            if (GoMatch.nearest(from: matchable, to: members)) {
                nearbyMatches.append(match)
            }
        }
        print("Matches encontrados despues de filtrar por h3 ", nearbyMatches.count)
        
        return nearbyMatches
    }
    
    func add(from match: GoMatch, requester: MongoRef) async throws -> GoMatch {
        let _ = try match
            .mustActive()
            .isCompleted()
        guard let _ = try? await userService.select(id: requester.id) else {
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
        let _ = try match
            .mustActive()
            .isCompleted()
        
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
        let _ = try match.mustActive()
        
        if match.leader != leader {
            if !match.requests.contains(requester) {
                throw Abort(.badRequest, reason: "Solo el alfitrion del grupo o quien realizo el request puede declinar una petición")
            }
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
    
    func getout(leader: MongoRef?, from match: GoMatch, getoutUser: MongoRef) async throws -> GoMatch {
        let _ = try match.mustActive()
        
        if match.leader != leader {
            if !match.members.contains(getoutUser) {
                throw Abort(.badRequest, reason: "Solo el alfitrion del grupo o quien realizo el request puede sacarlo del grupo")
            }
        }
        
        if match.members.remove(getoutUser) == nil {
            throw Abort(.badRequest, reason: "Se intentó sacar a un miembro que no es parte del grupo")
        }
        match.status = .processing
        
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
