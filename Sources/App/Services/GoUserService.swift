//
//  UserService.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 21/10/24.
//

import Vapor
import Fluent
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
    
    func populate(country: String, town: String) async throws -> [Place] {
        let matchCollection = mongodb[GoMatch.schema]
        let oneWeekAgo = Date().addingTimeInterval(-7 * 24 * 60 * 60)
        
        let groupDocument: Document = [
            "_id": [
                "country": "$destination.country",
                "city": "$destination.city",
                "name": "$destination.name"],
            "count": ["$sum": 1],
            "latitude": ["$first": "$destination.latitude"],
            "longitude": ["$first": "$destination.longitude"],
            "type": ["$first": "$destination.type"]
        ]
        
        // agregar filtro por pais y ciudad
        let pipeline: [AggregateBuilderStage] = [
            //.match("creation_date" >= oneWeekAgo),
            .match([
                "creation_date": ["$gte": oneWeekAgo],
                "destination.country": country,
                "destination.city": town,
            ]),
            .init(document: ["$group": groupDocument]),
        ]
        
        let groupedDocuments = try await matchCollection
            .aggregate(pipeline)
            .allResults()
        
        print(groupedDocuments.count)
        
        var places: [Place] = []
        for doc in groupedDocuments {
            print(doc)
            let details: Document = doc["_id"] as! Document
            
            places.append(
                Place(
                    country: details["country"] as! String,
                    city: details["city"] as! String,
                    name: details["name"] as! String,
                    type: doc["type"] as! String,
                    latitude: doc["latitude"] as! Double,
                    longitude: doc["longitude"] as! Double)
            )
        }
        
        return places
    }
}
