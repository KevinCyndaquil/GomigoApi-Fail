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
    
    init(database: any Database) throws {
        self.mongodb = try MongoController.client(db: database)
        self.db = database
        self.userService = try UserService(database: database)
    }
    
    func select(id: UUID) async throws -> GoMatch {
        guard let match = try? await GoMatch.query(on: db)
            .filter(\.$id == id)
            .first() else {
            throw Abort(.badRequest, reason: "id de match no encontrado")
        }
        return match
    }
    
    func generate(with unsaved: GoMatchPost) async throws -> GoMatch {
        let leader = try await userService.select(id: unsaved.leader.user.id)
        leader.matching = true
        leader.currentUbication = unsaved.leader.currentUbication
        
        let match = unsaved.toModel()
        match.requirements = leader.preferences
        
        try await leader.update(on: db)
        try await match.save(on: db)
        
        return match
    }
    
    func filter(match req: GoUserMatchable) async throws -> [GoMatch] {
        let _ = try await userService.select(id: req.user.id)
        
        guard var matches = try? await GoMatch.query(on: db)
            .sort(\.$status, .ascending)
            .filter(\.$status == .processing)
            .filter(\.$groupLength == req.groupLength)
            .all() else {
            throw Abort(.internalServerError, reason: "Error al buscar matches")
        }
        
        print("Match encontrado ", matches.count)
        
        matches = matches
            .filter ({
                $0.destination.distance(to: req.destination) <= maxDistanceFromCurrent
            })
            //aqui deben ir las preferencias del usuario xd
        
        var nearbyMatches: [GoMatch] = []
        for match in matches {
            let leader = try await userService.select(id: match.leader.id)
            
            var members: [GoUser] = [leader]
            for member in match.members {
                let user = try await userService.select(id: member.user.id)
                members.append(user)
            }
            
            if (GoMatch.nearest(from: req, to: members)) {
                nearbyMatches.append(match)
            }
        }
        return nearbyMatches
    }
    
    func add(from match: GoMatch, requester: GoUser) async throws -> GoMatch {
        try match.mustActive()
        
        let (inserted, _) = match.requests.insert(MongoRef(id: requester.id!))
        if !inserted {
            throw Abort(.badRequest, reason: "Usuario ya ha pedido unirse al grupo")
        }
        
        try await match.update(on: db)
        return match
    }
    
    func accept(leader: MongoRef, from match: GoMatch, newMember: GoUser) async throws -> GoMatch {
        try match.mustActive()
        
        if (match.leader != leader) {
            throw Abort(.badRequest, reason: "Solo el alfitrion del grupo puede aceptar peticiones de otros usuarios")
        }
        
        let requesterRef = MongoRef(id: newMember.id!)
        if match.requests.remove(requesterRef) == nil {
            throw Abort(.badRequest, reason: "Intentas aceptar una peticion de un usuario que no ha hecho ninguna request")
        }
            
        match.members.insert(GoMember(from: newMember))
        if match.members.count + 1 == match.groupLength {
            match.status = .matched
        }
        
        try await match.update(on: db)
        return match
    }
    
    func decline(leader: MongoRef?, from match: GoMatch, requester: GoUser) async throws -> GoMatch {
        try match.mustActive()
        let requesterRef = MongoRef(id: requester.id!)
        
        if (match.leader != leader || !match.requests.contains(requesterRef)) {
            throw Abort(.badRequest, reason: "Solo el alfitrion del grupo o quien realizo el request puede declinar una petición")
        }
        
        if match.requests.remove(requesterRef) == nil {
            throw Abort(.badRequest, reason: "Intentas declinar una peticion de un usuario que no ha hecho ninguna request")
        }
        
        try await match.update(on: db)
        return match
    }
    
    /*
    func add(from match: GoMatch, member: GoUser) async throws -> GoMatch {
        try match.mustActive()
        
        if match.leader.id == member.id! {
            throw Abort(.badRequest, reason: "el usuario que quieres agregar es ya el lider del grupo")
        }
        
        let (inserted, _) = match.members.insert(GoMember(from: member))
        if inserted {
            throw Abort(.badRequest, reason: "el usuario que quieres agregar ya se encontraba en tu equipo")
        }
        
        match.requirements = match.requirements!.intersection(with: member.preferences)
        
        try await match.update(on: db)
        return match
    }
    
    func kick(from match: GoMatch, member: GoUser) async throws -> GoMatch {
        if match.status == .canceled || match.status == .finalized {
            throw Abort(.badRequest, reason: "Intentas quitar integrantes de un match ya finalizado")
        }
        
        if match.leader.id == member.id && match.members.isEmpty {
            match.status = .canceled
            try await match.update(on: db)
            return match
        }
        if match.leader.id == member.id {
            match.leader = match.members.removeFirst().user
            print("sacando al lider")
        } else {
            if match.members.remove(GoMember(from: member)) == nil {
                throw Abort(.badRequest, reason: "removiendo usuario que no es integrante del grupo")
            }
        }
        
        let leader = try await userService.select(id: match.leader.id)
        var newPreference = leader.preferences
        
        for member in match.members {
            let savedMember = try await userService.select(id: member.user.id)
            newPreference = newPreference.intersection(with: savedMember.preferences)
        }
        match.requirements = newPreference
        
        try await match.update(on: db)
        return match
    }*/
}
