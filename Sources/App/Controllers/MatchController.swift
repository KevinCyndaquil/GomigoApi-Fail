//
//  MatchController.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 21/10/24.
//

import Vapor
import Fluent

struct MatchController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let matchRouter = routes.grouped("match")
        
        matchRouter.post("begin", use: self.begin)
        matchRouter.post("look", use: self.look)
    }
    
    @Sendable
    func begin(req: Request) async throws -> GoMatchDTO {
        let match = try req.content.decode(GoMatchPost.self).toModel()
        
        try await match.save(on: req.db)
        guard let matchDTO = try? await match.toDTO(db: req.db) else {
            throw Abort(.badRequest, reason: "references could not be saved before")
        }
        
        // estoy deberia hacerlo de forma asincrona
        Task {
            //let currentH3Index = H3Index(string: "8a6d2ad2ec17fff")
            //let currentIndex = match.currentUbication.toH3Index()
            guard let usersMatching = try? await GoMatch.query(on: req.db)
                .filter(\.$status == GoMatch.Status.processing)
                .filter(\.$id != match.id ?? UUID())
                .filter(\.$groupLength == match.groupLength)
                .all() else {
                    throw Abort(.internalServerError, reason: "error al buscar todos los usuarios intentando hacer matching")
                }
            
            print("estan estos para hacer match " + String(usersMatching.count))
            
            /*let matchesH3Index: [H3Index] = [
                H3Index(string: "8a6d2ad2eca7fff"),
                H3Index(string: "8a6d2ad2ed9ffff"),
                H3Index(string: "8a6d2ad2336ffff"),
                H3Index(string: "8a6d2ad2ecb7fff"),
                H3Index(string: "8a6d2ad2ed8ffff"),
            ]*/
            
            //let usersMatchingH3Index = usersMatching
                //.map { $0.currentUbication.toH3Index() }
            //let matchedIndexes = currentIndex.nearest(from: usersMatchingH3Index)
            
            let matchedUser = match.nearest(from: usersMatching)
            
            /*for m in matchedIndexes {
                print(String(format: "%lx", m.value))
            }*/
            
            try await Task.sleep(nanoseconds: 10_000_000_000)
            
            if (matchedUser.isEmpty) {
                guard let asyncMatch = try await GoMatch.query(on: req.db)
                    .filter(\.$id == match.id ?? UUID())
                    .first() else {
                        throw "no se pudo obtener el id del async match"
                    }
                
                if asyncMatch.status == .processing {
                    match.status = .not_matched
                    print("se cambio el estatus del match a not_matched")
                }
                
            } else {
                match.status = .matched
                
                for matched in matchedUser {
                    matched.status = .matched
                    try await matched.update(on: req.db)
                }
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
}
