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
        matchRouter.put("getout", use: self.getout)
        
        let responseRoute = matchRouter.grouped("responses")
        responseRoute.put("accept", use: self.accept)
        responseRoute.put("decline", use: self.decline)
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
        
        let postable = try req.content.decode(GoUserMatchable.self)
        let match = try await matchService.generate(with: postable)
        
        return try await match.toDTO(db: req.db)
    }
    
    @Sendable
    func look(req: Request) async throws -> Response {
        let matchService = try GoMatchService(on: req.db)
        
        guard let request = try? req.content.decode(GoMatchRequest.self) else {
            throw Abort(.badRequest, reason: "match reference no es entendible")
        }
        let match = try await matchService.look(request: request)
        
        switch match.status {
        case .processing:
            let response = Response(status: .accepted)
            let jsonBody = try await match.toDTO(db: req.db)
            try response.content.encode(jsonBody, as: .json)
            response.headers.add(name: .contentType, value: "application/json")
            
            return response
        case .matched:
            let travelService = try GoTravelService(on: req.db)
            let travel = try await travelService
                .select(id: match.travel!.id)
                .toDTO(db: req.db)
            let response = Response(status: .ok)
            try response.content.encode(travel, as: .json)
            response.headers.add(name: .contentType, value: "application/json")
            
            return response
        case .canceled:
            throw Abort(.unprocessableEntity, reason: "El match ha sido cancelado por el lider del grupo")
        case .finalized:
            throw Abort(.unprocessableEntity, reason: "El match ya ha finalizado correctamente")
        }
    }
    
    @Sendable
    func filter(req: Request) async throws -> [GoMatchDTO] {
        guard let matchable = try? req.content.decode(GoUserMatchable.self) else {
            throw Abort(.badRequest, reason: "usuario matchable no es entendible")
        }
        let matchService = try GoMatchService(on: req.db)
        
        let matches = try await matchService.filter(matchable: matchable)
        
        var matchesDTO: [GoMatchDTO] = []
        for match in matches {
            matchesDTO.append(try await match.toDTO(db: req.db))
        }
        
        return matchesDTO
    }
    
    @Sendable
    func request(req: Request) async throws -> GoMatchDTO {
        let matchService = try GoMatchService(on: req.db)
        
        guard let matchable = try? req.content.decode(GoMatchRequest.self) else {
            throw Abort(.badRequest, reason: "Match request no es entendible")
        }
        
        let match = try await matchService.select(id: matchable.matchId.id)
        let updatedMatch = try await matchService.add(from: match, requester: matchable.requesterId)
        
        return try await updatedMatch.toDTO(db: req.db)
    }
    
    @Sendable
    func accept(req: Request) async throws -> GoMatchDTO {
        let matchService = try GoMatchService(on: req.db)
        
        guard let response = try? req.content.decode(GoMatchResponse.self) else {
            throw Abort(.badRequest, reason: "match response no es entendible")
        }
        let match = try await matchService.select(id: response.matchId.id)
        
        let acceptedMatch = try await matchService.accept(from: match, responser: response.fromUser, requester: response.replyToUser)
        
        return try await acceptedMatch.toDTO(db: req.db)
    }
    
    @Sendable
    func decline(req: Request) async throws -> Response {
        let matchService = try GoMatchService(on: req.db)
        
        guard let response = try? req.content.decode(GoGetoutMatch.self) else {
            throw Abort(.badRequest, reason: "match getout no es entendible")
        }
        let match = try await matchService.select(id: response.matchId.id)
        
        _ = try await matchService.decline(leader: response.requesterId, from: match, requester: response.userToGetout)
        
        if response.requesterId == match.leader {
            return Response(status: .ok, body: "Se ha eliminado la petición correctamente")
        } else {
            return Response(status: .ok, body: "Se ha denegado la petición exitosamente")
        }
    }
    
    @Sendable
    func getout(req: Request) async throws -> Response {
        let matchService = try GoMatchService(on: req.db)
        
        guard let request = try? req.content.decode(GoGetoutMatch.self) else {
            throw Abort(.badRequest, reason: "Match getout no es entendible")
        }
        let match = try await matchService.select(id: request.matchId.id)
        
        _ = try await matchService.getout(leader: request.requesterId, from: match, getoutUser: request.userToGetout)
        
        if request.requesterId == match.leader {
            return Response(status: .ok, body: "Se ha sacado a un miembro del grupo correctamente correctamente")
        } else {
            return Response(status: .ok, body: "Te has salido del grupo exitosamente")
        }
    }
    
    @Sendable
    func checkResponse(req: Request) async throws -> GoMatchDTO {
        guard let request = try? req.content.decode(GoMatchRequest.self) else {
            throw Abort(.badRequest, reason: "match request no es entendible")
        }
        let matchService = try GoMatchService(on: req.db)
        let match = try await matchService.select(id: request.matchId.id)
        
        return try await matchService.wasAccepted(match: match, requester: request.requesterId).toDTO(db: req.db)
    }
}
