//
//  MatchService.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 25/10/24.
//

import Vapor
import Fluent
import MongoKitten

struct MatchService {
    let mongodb: MongoDatabase
    let db: any Database
    
    init(mongodb: MongoDatabase, db: any Database) {
        self.mongodb = mongodb
        self.db = db
    }
    
    func getMatchesFrom(link linkId: UUID) async throws -> [GoMatch] {
        try await GoMatch.query(on: db)
            .filter(\.$)
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
