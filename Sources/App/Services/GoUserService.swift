//
//  UserService.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 21/10/24.
//

import Vapor
import Fluent
import FluentMongoDriver
import MongoKitten

final class GoUserService {
    let db: any Database
    let mongodb: MongoDatabase
    
    init(on: any Database) throws {
        self.db = on
        self.mongodb = try MongoController.client(db: self.db)
    }
    
    func select(id: UUID) async throws -> GoUser {
        guard let user = try? await GoUser.query(on: db)
            .filter(\.$id == id)
            .first() else {
                throw Abort(.internalServerError, reason: "id de usuario no encontrada")
            }
        return user;
    }
    
    func login(credential: Credentials) async throws -> GoUser {
        guard let user = try? await GoUser.query(on: db)
            .filter(\.$nickname == credential.username)
            .filter(\.$password == credential.password)
            .first() else {
            throw Abort(.unauthorized, reason: "credenciales invalidas")
        }
        user.online = true
        try await user.update(on: db)
        
        return user
    }
    
    func setLocation(matchable: GoUserMatchable) async throws {
        let user = try await select(id: matchable.userFindingMatches.id)
        
        user.currentUbication = matchable.currentUbication
        try await user.update(on: db)
    }
}
