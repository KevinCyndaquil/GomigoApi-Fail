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

final class UserService {
    let db: any Database
    let mongodb: MongoDatabase
    
    init(database: any Database) throws {
        self.db = database
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
        return user
    }
}
