//
//  GoTravelService.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 31/10/24.
//

import Vapor
import Fluent
import MongoKitten

final class GoTravelService {
    let mongodb: MongoDatabase
    let db: any Database
    
    let userService: GoUserService
    
    init(on db: any Database) throws {
        self.mongodb = try MongoController.client(db: db)
        self.db = db
        self.userService = try GoUserService(on: db)
    }
    
    func select(id: UUID) async throws -> GoTravel {
        guard let travel = try? await GoTravel.query(on: db)
            .filter(\.$id == id)
            .first() else {
            throw Abort(.badRequest, reason: "no se encontró el viaje por id")
        }
        return travel
    }
    
    func look(request: GoTravelRequest) async throws -> GoTravel {
        let travel = try await select(id: request.travelId.id)
        
        if travel.traveler != request.fromUser {
            throw Abort(.unauthorized, reason: "no eres parte del viaje o necesitas confirmar tu participación para ver su status")
        }
        
        return travel
    }
    
    func arriveMeetingPoint(_ travelRef: MongoRef) async throws -> GoTravel {
        let travel = try await select(id: travelRef.id)
        travel.status = .at_meeting_point
        
        try await travel.update(on: db)
        return travel
    }
    
    func goingToDestination(_ travelRef: MongoRef) async throws -> GoTravel {
        let travel = try await select(id: travelRef.id)
        travel.status = .on_road
        
        try await travel.update(on: db)
        return travel
    }
    
    func arriveDestination(_ travelRef: MongoRef) async throws -> GoTravel {
        let travel = try await select(id: travelRef.id)
        travel.status = .finished
        
        try await travel.update(on: db)
        return travel
    }
}
