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
        var match = unsaved.toModel()
        
        try await match.save(on: db)
        
        return match
    }
    
    func filter(match req: GoUserMatchable) async throws -> [GoMatch] {
        guard var matches = try? await GoMatch.query(on: db)
            .sort(\.$status, .ascending)
            .group(.or, { $0
                .filter(\.$status == .processing)
                .filter(\.$status == .waiting)
            })
            .filter(\.$id != req.id)
            .filter(\.$groupLength == req.groupLength)
            .all() else {
            throw Abort(.internalServerError, reason: "Error al buscar matches")
        }
        
        matches = matches.filter {
            $0.destination.distance(to: req.destination) <= maxDistanceFromCurrent
        }
        
        let nearbyMatches = 
        
        return []
    }
    
    func add(from match: GoMatch, member: GoMember) async throws {
        guard let sMember = try? await userService.select(id: member.user.id) else {
            throw Abort(.badRequest, reason: "id de member no encontrado")
        }
        
        if match.leader == nil {
            match.leader = member.user
        } else {
            match.members.insert(member)
        }
        match.requirements = match.requirements.intersection(with: sMember.preferences)
    }
    
    func kick(from match: GoMatch, member: GoMember) async throws {
        if match.leader == member.user && !match.members.isEmpty {
            match.leader = match.members.removeFirst().user
        } else {
            match.members.remove(member)
        }
        
        guard let leader = try? await userService.select(id: match.leader!.id) else {
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
    }
    
    func checkLinkedMatches(from match: GoMatch) async throws -> [GoMatch] {
        let aggregationGroup: Document = [
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
        }
        
        return linkedMatches
    }
}
