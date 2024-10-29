//
//  GoTravelController.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 29/10/24.
//

import Vapor
import Fluent

final class GoTravelController: RouteCollection {
    
    func boot(routes: any RoutesBuilder) throws {
        let travelRoute = routes.grouped("travel")
        let responsesRoute = travelRoute.grouped("responses")
        
        responsesRoute.post("accept", use: self.accept)
        responsesRoute.put("decline", use: self.decline)
    }
    
    @Sendable
    func accept(req: Request) async throws -> String {
        let travelDTO = try req.content.decode(GoTravelDTO.self)
        
        return "hola"
    }
    
    @Sendable
    func decline(req: Request) async throws -> String {
        return "xd"
    }
}
