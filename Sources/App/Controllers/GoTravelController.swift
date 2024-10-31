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
        
    }
    
    @Sendable
    func look(req: Request) async throws -> GoTravelDTO {
        let request = try req.content.decode(GoTravelRequest.self)
        let travelService = try GoTravelService(on: req.db)
        
        return try await travelService
            .look(request: request)
            .toDTO(db: req.db)
    }
}
