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
    
    init(mongodb: MongoDatabase, db: any Database) {
        self.mongodb = mongodb
        self.db = db
        self.userService = UserService(database: db)
    }
    
    func generate(with unsaved: GoMatchPost) async throws -> GoMatch {
        guard let leader = try? await userService.select(id: unsaved.leader.user.id) else {
            throw Abort(.badRequest, reason: "leader id no valida")
        }
        leader.matching = true
        let match = unsaved.toModel()
        match.requirements = leader.preferences
        
        try await leader.update(on: db)
        try await match.save(on: db)
        
        return match
    }
    
    func filter(match req: GoUserMatchable) async throws -> [GoMatch] {
        guard let _ = try? await GoUser.query(on: db)
            .filter(\.$id == req.user.id)
            .first() else {
            throw Abort(.badRequest, reason: "Usuario invalido")
        }
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
            guard let leader = try? await userService.select(id: match.leader.id) else {
                throw Abort(.badRequest, reason: "No se pudo encontrar a el leader")
            }
            
            var members: [GoUser] = [leader]
            for member in match.members {
                guard let user = try? await userService.select(id: member.user.id) else {
                    throw Abort(.badRequest, reason: "id de miembro invalido")
                }
                members.append(user)
            }
            
            if (GoMatch.nearest(from: req, to: members)) {
                nearbyMatches.append(match)
            }
        }
        return nearbyMatches
    }
    
    func add(from match: GoMatch, member: GoUser) async throws -> GoMatch {
        if match.status == .canceled || match.status == .finalized {
            throw Abort(.badRequest, reason: "Intentas agregar integrantes de un match ya finalizado")
        }
        
        if match.groupLength == match.members.count + 1 {
            throw Abort(.badRequest, reason: "el grupo ya está completo")
        }
        
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
        
        guard let leader = try? await userService.select(id: match.leader.id) else {
            throw Abort(.badRequest, reason: "id de lider no encontrada")
        }
        var newPreference = leader.preferences
        
        for member in match.members {
            guard let sMember = try? await userService.select(id: member.user.id) else {
                throw Abort(.badRequest, reason: "id de miembro no encontrado")
            }
            newPreference = newPreference.intersection(with: sMember.preferences)
        }
        match.requirements = newPreference
        
        try await match.update(on: db)
        return match
    }
    
    func checkLinkedMatches(from match: GoMatch) async throws -> [GoMatch] {
        /*let aggregationGroup: Document = [
            "_id": "$link_id",
            "count": ["$sum": 1],
            "group_length": ["$first": "$group_length"]
        ]
        
        let aggregationPipeline: [AggregateBuilderStage] = [
            .match(["_id": ["$ne": match.id!.uuidString]]),
            .init(document: ["$group": aggregationGroup]),
            .match(["$expr": ["$lt": ["$count", "$group_length"]]]),
            .sort(["count": .descending]),
        ]
        
        let results = try await mongodb[GoMatch.schema]
            .aggregate(aggregationPipeline).execute().get()
        
        var linkedMatches: [GoMatch] = []
        for try await doc in results {
            guard let linkStringId = doc["_id"] as? String else {
                throw Abort(.internalServerError, reason: "ocurrio un error obteniendo el link id de los matches")
            }
            let linkId = UUID(uuidString: linkStringId)
            
            guard let linked = try? await GoMatch.query(on: db)
                .filter(\.$linkId == linkId)
                .all() else {
                throw Abort(.internalServerError, reason: "ocurrio un error obteniendos los matches ligados a link id")
            }
            linkedMatches.append(contentsOf: linked)
            
            for l in linked {
                print(l.id ?? "nil", " ", l.linkId ?? "nil")
            }
        }*/
        
        return []
    }
}
