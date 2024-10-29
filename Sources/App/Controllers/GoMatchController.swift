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
        matchRouter.post("filter", use: self.filter)
        matchRouter.post("request", use: self.request)
        matchRouter.put("response", use: self.accept)
        matchRouter.put("decline", use: self.decline)
        
        let responseRoute = matchRouter.grouped("responses")
        responseRoute.post("client", use: self.checkResponse)
    }
    
    /// This  resource starts the matching process, doing this:
    /// * Generates the unique UUID for this match instance
    /// * Returns a ok response with the UUID generated,
    ///   and starts the matching process.
    /// * Gets all matches, filtering by each property needed.
    @Sendable
    func begin(req: Request) async throws -> GoMatchDTO {
        let matchService = try GoMatchService(on: req.db)
        
        let matchPost = try req.content.decode(GoMatchPostable.self)
        let match = try await matchService.generate(with: matchPost)
        
        return try await match.toDTO(db: req.db)
    }
    
    @Sendable
    func look(req: Request) async throws -> GoMatchDTO {
        let matchService = try GoMatchService(on: req.db)
        
        guard let matchRef: MongoRef = try? req.content.decode(MongoRef.self) else {
            throw Abort(.badRequest, reason: "match id es invalida")
        }
        
        let match = try await matchService.select(id: matchRef.id)
        
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
        let matchService = try GoMatchService(on: req.db)
        
        let matches = try await matchService.filter(matchable: matchable)
        var matchesDTO: [GoMatchDTO] = []
        
        for match in matches {
            let dto = try await match.toDTO(db: req.db)
            matchesDTO.append(dto)
        }
        
        return matchesDTO
    }
    
    @Sendable
    func request(req: Request) async throws -> GoMatchDTO {
        let userService = try UserService(database: req.db)
        let matchService = try GoMatchService(on: req.db)
        
        guard let matchable = try? req.content.decode(GoMatchRequest.self) else {
            throw Abort(.badRequest, reason: "Match request invalida")
        }
        
        print("hola bb")
        
        let match = try await matchService.select(id: matchable.matchId.id)
        let updatedMatch = try await matchService.add(from: match, requester: matchable.requesterId)
        
        return try await updatedMatch.toDTO(db: req.db)
    }
    
    @Sendable
    func accept(req: Request) async throws -> GoMatch {
        let matchService = try GoMatchService(on: req.db)
        let userService = matchService.userService
        
        guard let response = try? req.content.decode(GoMatchResponse.self) else {
            throw Abort(.badRequest, reason: "match id es invalida")
        }
        let match = try await matchService.select(id: response.matchId.id)
        
        try match.mustActive()
        return try await matchService.accept(from: match, responser: response.fromUser, requester: response.replyToUser)
    }
    
    @Sendable
    func decline(req: Request) async throws -> Response {
        let matchService = try GoMatchService(on: req.db)
        let userService = matchService.userService
        
        guard let response = try? req.content.decode(GoMatchResponse.self) else {
            throw Abort(.badRequest, reason: "match id es invalida")
        }
        let match = try await matchService.select(id: response.matchId.id)
        let user = try await userService.select(id: response.replyToUser.id)
        
        try match.mustActive()
        let _ = try await matchService.decline(leader: response.fromUser, from: match, requester: response.replyToUser)
        
        if response.fromUser == match.leader {
            return Response(status: .ok, body: "Se ha eliminado la petición correctamente")
        } else {
            return Response(status: .ok, body: "Se ha denegado la petición exitosamente")
        }
    }
    
    @Sendable
    func checkResponse(req: Request) async throws -> GoMatch {
        guard let request = try? req.content.decode(GoMatchRequest.self) else {
            throw Abort(.badRequest, reason: "Objeto invalido")
        }
        let matchService = try GoMatchService(on: req.db)
        let match = try await matchService.select(id: request.matchId.id)
        
        return try matchService.wasAccepted(match: match, requester: request.requesterId)
    }
}
