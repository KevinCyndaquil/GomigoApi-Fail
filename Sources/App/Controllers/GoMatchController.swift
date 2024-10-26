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
        matchRouter.post("link", use: self.link)
        matchRouter.put("unlink", use: self.unlink)
        matchRouter.post("filter", use: self.filter)
    }
    
    /// This  resource starts the matching process, doing this:
    /// * Generates the unique UUID for this match instance
    /// * Returns a ok response with the UUID generated,
    ///   and starts the matching process.
    /// * Gets all matches, filtering by each property needed.
    @Sendable
    func begin(req: Request) async throws -> GoMatchDTO {
        let mongodb = try MongoController.client(db: req.db)
        let matchService = GoMatchService(mongodb: mongodb, db: req.db)
        
        let matchPost = try req.content.decode(GoMatchPost.self)
        guard let match = try? await matchService.generate(with: matchPost) else {
            throw Abort(.badRequest, reason: "no se pudo generar el match")
        }
        
        return try await match.toDTO(db: req.db)
        /*let availableSpaces = match.groupLength - 1
        
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
        }*/
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
        
        switch match.status {
        case .processing, .matched:
            return try await match.toDTO(db: req.db);
        case .canceled:
            throw Abort(.badRequest, reason: "El match ha sido cancelado por el lider del grupo")
        case .finalized:
            throw Abort(.ok, reason: "El match ya ha finalizado correctamente")
        }
    }
    
    @Sendable
    func filter(req: Request) async throws -> [GoMatchDTO] {
        guard let matchable = try? req.content.decode(GoUserMatchable.self) else {
            throw Abort(.badRequest, reason: "Objeto invalido")
        }
        let mongodb = try MongoController.client(db: req.db)
        let matchService = GoMatchService(mongodb: mongodb, db: req.db)
        
        guard let matches = try? await matchService.filter(match: matchable) else {
            throw Abort(.badRequest, reason: "No se pudo realizar un filter")
        }
        var matchesDTO: [GoMatchDTO] = []
        for match in matches {
            let dto = try await match.toDTO(db: req.db)
            matchesDTO.append(dto)
        }
        
        return matchesDTO
    }
    
    @Sendable
    func link(req: Request) async throws -> GoMatchDTO {
        guard let matchable = try? req.content.decode(GoUserMatchable.self) else {
            throw Abort(.badRequest, reason: "match id es invalida")
        }
        
        guard let match = try? await GoMatch.query(on: req.db)
            .filter(\.$id == matchable.matchId!)
            .group(.and, { $0
                .filter(\.$status != .finalized)
                .filter(\.$status != .canceled)
            })
            .first() else {
            throw Abort(.badRequest, reason: "id de match no encontrado")
        }
        guard let user = try? await GoUser.query(on: req.db)
            .filter(\.$id == matchable.user.id)
            .first() else {
            throw Abort(.badRequest, reason: "id de usuario no encontrada")
        }
        
        let mongodb = try MongoController.client(db: req.db)
        let matchService = GoMatchService(mongodb: mongodb, db: req.db)
        
        guard let match = try? await matchService.add(from: match, member: user) else {
            throw Abort(.internalServerError, reason: "ocurrió un error haciendo un link de usuarios")
        }
        return try await match.toDTO(db: req.db)
    }
    
    @Sendable
    func unlink(req: Request) async throws -> Response {
        guard let matchFinalized = try? req.content.decode(GoMatchFinalized.self) else {
            throw Abort(.badRequest, reason: "match id es invalida")
        }
        
        guard let match = try? await GoMatch.query(on: req.db)
            .filter(\.$id == matchFinalized.match.id)
            .first() else {
            throw Abort(.badRequest, reason: "id de match no encontrado")
        }
        guard let user = try? await GoUser.query(on: req.db)
            .filter(\.$id == matchFinalized.user.id)
            .first() else {
            throw Abort(.badRequest, reason: "id de usuario no encontrada")
        }
        
        if (match.status == .finalized || match.status == .canceled){
            return Response(status: .ok, body: "Match ya había sido finalizado")
        }
        
        let mongodb = try MongoController.client(db: req.db)
        let matchService = GoMatchService(mongodb: mongodb, db: req.db)
        
        let _ = try await matchService.kick(from: match, member: user)
        
        return Response(status: .ok, body: "El grupo ha sido disuelto correctamente")
        
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
    }
}
