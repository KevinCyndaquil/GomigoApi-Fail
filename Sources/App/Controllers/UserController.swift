//
//  UserContrller.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 18/10/24.
//

import Vapor
import Fluent

struct UserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let userRoute = routes.grouped("user")
        
        userRoute.get(use: self.index)
        userRoute.post(use: self.register)
    }
    
    @Sendable
    func index(req: Request) async throws -> [GoUser] { 
        try await GoUser.query(on: req.db).all()
    }
    
    @Sendable
    func register(req: Request) async throws -> GoUser {
        let goUser = try req.content.decode(GoUserPost.self).toModel()
        
        // hacer algo para validar los datos del usuario
        
        try await goUser.save(on: req.db)
        return goUser
    }

}
