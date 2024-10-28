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
        //matchRouter.post("link", use: self.link)
        //matchRouter.put("unlink", use: self.unlink)
        matchRouter.post("filter", use: self.filter)
        matchRouter.post("request", use: self.request)
        matchRouter.put("response", use: self.accept)
        matchRouter.put("decline", use: self.decline)
    }
    
    /// This  resource starts the matching process, doing this:
    /// * Generates the unique UUID for this match instance
    /// * Returns a ok response with the UUID generated,
    ///   and starts the matching process.
    /// * Gets all matches, filtering by each property needed.
    @Sendable
    func begin(req: Request) async throws -> GoMatchDTO {
        let matchService = try GoMatchService(database: req.db)
        
        let matchPost = try req.content.decode(GoMatchPost.self)
        guard let match = try? await matchService.generate(with: matchPost) else {
            throw Abort(.badRequest, reason: "no se pudo generar el match")
        }
        
        return try await match.toDTO(db: req.db)
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
        let matchService = try GoMatchService(database: req.db)
        
        let matches = try await matchService.filter(match: matchable)
        var matchesDTO: [GoMatchDTO] = []
        
        for match in matches {
            let dto = try await match.toDTO(db: req.db)
            matchesDTO.append(dto)
        }
        
        return matchesDTO
    }
    
    /*@Sendable
    func link(req: Request) async throws -> GoMatchDTO {
        let userService = try UserService(database: req.db)
        let matchService = try GoMatchService(database: req.db)
        
        guard let matchable = try? req.content.decode(GoUser.self) else {
            throw Abort(.badRequest, reason: "match id es invalida")
        }
        
        if matchable.
        
        print("hola bb")
        
        let match = try await matchService.select(id: matchable.matchId!)
        let user = try await userService.select(id: matchable.user.id)
        let updatedMatch = try await matchService.add(from: match, requester: user)
        
        return try await updatedMatch.toDTO(db: req.db)
    }
    
    @Sendable
    func unlink(req: Request) async throws -> Response {
        let matchService = try GoMatchService(database: req.db)
        let userService = matchService.userService
        
        guard let matchFinalized = try? req.content.decode(GoMatchFinalized.self) else {
            throw Abort(.badRequest, reason: "match id es invalida")
        }
        let match = try await matchService.select(id: matchFinalized.match.id)
        let user = try await userService.select(id: matchFinalized.user.id)
        
        try match.mustActive()
        let _ = try await matchService.decline(leader: matchFinalized.leader, from: match, requester: user)
        
        if matchFinalized.leader == nil {
            return Response(status: .ok, body: "Se ha eliminado la petición correctamente")
        } else {
            return Response(status: .ok, body: "Se ha denegado la petición exitosamente")
        }
    }*/
    
    @Sendable
    func request(req: Request) async throws -> GoMatchDTO {
        let userService = try UserService(database: req.db)
        let matchService = try GoMatchService(database: req.db)
        
        guard let matchable = try? req.content.decode(GoMatchRequest.self) else {
            throw Abort(.badRequest, reason: "Match request invalida")
        }
        
        print("hola bb")
        
        let match = try await matchService.select(id: matchable.matchId.id)
        let user = try await userService.select(id: matchable.requesterId.id)
        let updatedMatch = try await matchService.add(from: match, requester: user)
        
        return try await updatedMatch.toDTO(db: req.db)
    }
    
    @Sendable
    func accept(req: Request) async throws -> GoMatch {
        let matchService = try GoMatchService(database: req.db)
        let userService = matchService.userService
        
        guard let response = try? req.content.decode(GoMatchResponse.self) else {
            throw Abort(.badRequest, reason: "match id es invalida")
        }
        let match = try await matchService.select(id: response.matchId.id)
        let replyUser = try await userService.select(id: response.replyToUser.id)
        
        try match.mustActive()
        return try await matchService.accept(leader: response.fromUser, from: match, newMember: replyUser)
    }
    
    @Sendable
    func decline(req: Request) async throws -> Response {
        let matchService = try GoMatchService(database: req.db)
        let userService = matchService.userService
        
        guard let response = try? req.content.decode(GoMatchResponse.self) else {
            throw Abort(.badRequest, reason: "match id es invalida")
        }
        let match = try await matchService.select(id: response.matchId.id)
        let user = try await userService.select(id: response.replyToUser.id)
        
        try match.mustActive()
        let _ = try await matchService.decline(leader: response.fromUser, from: match, requester: user)
        
        if response.fromUser == match.leader {
            return Response(status: .ok, body: "Se ha eliminado la petición correctamente")
        } else {
            return Response(status: .ok, body: "Se ha denegado la petición exitosamente")
        }
    }
}
