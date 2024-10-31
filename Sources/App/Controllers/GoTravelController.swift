//
//  GoTravelController.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 29/10/24.
//

import Vapor
import Fluent

struct GoTravelController: RouteCollection {
    
    func boot(routes: any RoutesBuilder) throws {
        let travelRoute = routes.grouped("travel")
        
        travelRoute.post("look", use: self.look)
        
        let responsesRoute = travelRoute.grouped("responses")
        responsesRoute.post("accept", use: self.accept)
        responsesRoute.put("decline", use: self.decline)
    }
    
    @Sendable
    func look(req: Request) async throws -> GoTravelDTO {
        let request = try req.content.decode(GoTravelRequest.self)
        let travelService = try GoTravelService(on: req.db)
        
        return try await travelService
            .look(request: request)
            .toDTO(db: req.db)
    }
    
    @Sendable
    func accept(req: Request) async throws -> GoTravelDTO {
        let request = try req.content.decode(GoTravelRequest.self)
        let travelService = try GoTravelService(on: req.db)
        
        let travel = try await travelService.select(id: request.travelId.id)
        try await travelService.accept(traveler: request.fromUser, travel: travel)
        
        return try await travel.toDTO(db: req.db)
    }
    
    @Sendable
    func decline(req: Request) async throws -> GoTravelDTO {
        let request = try req.content.decode(GoTravelRequest.self)
        let travelService = try GoTravelService(on: req.db)
        
        let travel = try await travelService.select(id: request.travelId.id)
        try await travelService.decline(traveler: request.fromUser, travel: travel)
        
        return try await travel.toDTO(db: req.db)
    }
}
