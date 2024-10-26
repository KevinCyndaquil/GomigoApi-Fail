//
//  MatchController.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 21/10/24.
//

import Vapor
import Fluent
import MongoKitten
import FluentMongoDriver

struct GoMatchController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let matchRouter = routes.grouped("match")
        
        matchRouter.post("begin", use: self.begin)
        matchRouter.post("look", use: self.look)
        matchRouter.post("cancel", use: self.cancel)
    }
    
    func checkLinked(mongodb: MongoDatabase, db: any Database, match: GoMatch) async throws -> [GoMatch] {
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
    
    /// This  resource starts the matching process, doing this:
    /// * Generates the unique UUID for this match instance
    /// * Returns a ok response with the UUID generated,
    ///   and starts the matching process.
    /// * Gets all matches, filtering by each property needed.
    /// *
    @Sendable
    func begin(req: Request) async throws -> GoMatchDTO {
        guard let database: MongoDatabaseRepresentable = req.db as? MongoDatabaseRepresentable else {
            throw Abort(.internalServerError)
        }
        let mongodb = database.raw
        
        let match = try req.content.decode(GoMatchPost.self).toModel()
        let availableSpaces = match.groupLength - 1
        
        try await match.save(on: req.db)
        guard let matchDTO = try? await match.toDTO(db: req.db) else {
            throw Abort(.badRequest, reason: "references could not be saved before")
        }
        
        // estoy deberia hacerlo de forma asincrona
        Task {
            let linkedMatches: [GoMatch] = try await checkLinked(mongodb: mongodb, db: req.db, match: match)
            
            // Here, we filter for each basic property
            guard var usersMatching: [GoMatch] = try? await GoMatch.query(on: req.db)
                .sort(\.$status, .ascending)
                .group(.or, { group in
                    group
                        .filter(\.$status == GoMatch.Status.processing)
                        .filter(\.$status == GoMatch.Status.waiting)
                })
                .filter(\.$id != match.id ?? UUID())
                .filter(\.$groupLength == match.groupLength)
                .all() else {
                    throw Abort(.internalServerError, reason: "error al buscar todos los usuarios intentando hacer matching")
                }
            
            print("estan estos para comenzar " + String(usersMatching.count))
            
            // Here, we filter for destination distance
            usersMatching = usersMatching.filter {
                $0.destination.distance(to: match.destination) <= 20
            }
            
            usersMatching = linkedMatches + usersMatching
        
            for user in usersMatching {
                print(user.id?.uuidString ?? "nil")
            }
            
            print("estan estos para hacer match " + String(usersMatching.count))
            
            // Here, we get all current ubication nearby of us
            let matchedUsers = match.nearest(from: usersMatching)
            
            // Here, we can improve the sleep process, probably no needed
            try await Task.sleep(nanoseconds: 20_000_000_000)
            
            if (matchedUsers.count < availableSpaces) {
                let asyncMatch = try await GoMatch.query(on: req.db)
                    .filter(\.$id == match.id ?? UUID())
                    .filter(\.$status == .processing)
                    .first()
                
                if asyncMatch != nil {
                    match.status = .waiting
                    print("se cambio el estatus del match a waiting")
                }

            } else {
                var upUUID: Set<UUID> = [ match.id! ]
                //var updatingUUID: [String] = [ match.id?.uuidString ?? "nil" ]
                
                for i in 0..<availableSpaces {
                    upUUID.insert(usersMatching[i].id!)
                    //updatingUUID.append(usersMatching[i].id?.uuidString ?? "nil")
                    print(usersMatching[i].id?.uuidString ?? "nil")
                }
                
                // Here, we generate a unique UUID to link the matched users
                let linkId = UUID()
                // Only check if any user did not cancel his match
                let anyCanceled: Set<UUID> = Set(try await GoMatch.query(on: req.db)
                    .filter(\.$status == .finished)
                    .all()
                    .map {
                        $0.id!
                    })
                upUUID = upUUID.subtracting(anyCanceled)
                
                let filter: Document = [
                    "_id": [ "$in": upUUID.map { $0.uuidString } ]
                ]
                var update: Document = [:]
                update["status"] = GoMatch.Status.linked.rawValue
                update["link_id"] = linkId.uuidString
                
                let result = try await mongodb[Documents.match.rawValue]
                    .updateMany(where: filter, to: ["$set": update]).get()
                
                print("resultados " + String(result.updatedCount))
                
                return;
            }
            
            try await match.update(on: req.db)
        }
        
        return matchDTO
    }
    
    @Sendable
    func look(req: Request) async throws -> GoMatchDTO {
        guard let matchRef: MongoRef = try? req.content.decode(MongoRef.self) else {
            throw Abort(.badRequest, reason: "match id es invalida")
        }
        
        guard let match = try? await GoMatch.query(on: req.db)
            .filter(\.$id == matchRef.id)
            .first() else {
            throw Abort(.notFound, reason: "id de match no encontrado")
        }
        
        if match.status != .linked {
            if match.status == .finished {
                throw Abort(.badRequest, reason: "al parecer, el match ya ha sido finalizado")
            }
            if match.status == .finished_by_other {
                throw Abort(.accepted, reason: "al parecer, un usuario con el que habias hecho match ya ha cancelado tu match")
            }
            if match.status == .processing {
                throw Abort(.found, reason: "seguimos procesando el match")
            }
            if match.status == .not_matched {
                throw Abort(.unprocessableEntity, reason: "no pudimos encontrar un match")
            }
            if match.status == .matched {
                return try await match.toDTO(db: req.db)
            }
            throw Abort(.internalServerError, reason: "no se procesa el estatus del match")
        }
        
        guard let linkedMatches = try? await GoMatch.query(on: req.db)
            .filter(\.$linkId == match.linkId)
            .all() else {
            throw Abort(.notFound, reason: "link id de match no encontro los matches")
        }
        
        return try await match.toDTO(db: req.db)
    }
    
    @Sendable
    func cancel(req: Request) async throws -> Response {
        guard let matchRef: MongoRef = try? req.content.decode(MongoRef.self) else {
            throw Abort(.badRequest, reason: "match id es invalida")
        }
        
        guard let match = try? await GoMatch.query(on: req.db)
            .filter(\.$id == matchRef.id)
            .first() else {
            throw Abort(.notFound, reason: "id de match no encontrado")
        }
        
        if (match.status == .finished || match.status == .finished_by_other){
            return Response(status: .ok, body: "Match ya había sido finalizado")
        }
        
        match.status = .finished
        match.linkId = nil
        try await match.update(on: req.db)
        
        /*if match.linkId != nil {
            guard let linkedMatches = try? await GoMatch.query(on: req.db)
                .filter(\.$linkId == match.linkId)
                .all() else {
                throw Abort(.notFound, reason: "id de linked matches no encontrado")
            }
            for linkedMatch in linkedMatches {
                linkedMatch.status = .finished_by_other
                try await linkedMatch.update(on: req.db)
            }
        }*/
        
        return Response(status: .ok, body: "Match finalizado correctamente")
    }
}
