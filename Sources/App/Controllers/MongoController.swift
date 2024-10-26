//
//  MongoController.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 26/10/24.
//

import Vapor
import Fluent
import FluentMongoDriver
import MongoKitten

struct MongoController {
    
    static func client(db: any Database) throws -> MongoDatabase {
        guard let database: MongoDatabaseRepresentable = db as? MongoDatabaseRepresentable else {
            throw Abort(.internalServerError)
        }
        
        return database.raw
    }
}
