//
//  UserContrller.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 18/10/24.
//

import Vapor
import Fluent

struct GoUserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let userRoute = routes.grouped("user")
        
        userRoute.get(use: self.index)
        userRoute.post("register", use: self.register)
        userRoute.post("login", use: self.login)
        userRoute.put("localize", use: self.localize)
        userRoute.get("populate", use: self.populate)
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
    
    @Sendable
    func login(req: Request) async throws -> GoUser {
        let userService = try GoUserService(on: req.db)
        let credential = try req.content.decode(Credentials.self)
        
        return try await userService.login(credential: credential)
    }
    
    @Sendable
    func localize(req: Request) async throws -> GoUserDTO {
        let localizer = try req.content.decode(GoUserUbication.self)
        
        guard let user = try await GoUser.query(on: req.db)
            .filter(\.$id == localizer.id)
            .first() else {
            throw Abort(.badRequest, reason: "Usuario invalido")
        }
        user.currentUbication = localizer.currentUbication
        try await user.update(on: req.db)
        return user.toDTO()
    }
    
    @Sendable
    func populate(req: Request) async throws -> [Place] {
        let country = try req.query.get(String.self, at: "country")
        let town = try req.query.get(String.self, at: "town")
        
        let userService = try GoUserService(on: req.db)
        return try await userService.populate(country: country, town: town)
    }
}
