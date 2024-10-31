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
        
        if !travel.travelers.contains(request.fromUser) {
            throw Abort(.unauthorized, reason: "no eres parte del viaje o necesitas confirmar tu participación para ver su status")
        }
        
        return travel
    }
    
    func accept(traveler travelerRef: MongoRef, travel: GoTravel) async throws {
        _ = try await userService.select(id: travelerRef.id)
        if travel.posibleTravelers.remove(travelerRef) == nil {
            throw Abort(.badGateway, reason: "estás tratando de añadir a un usuario que no es parte del viaje")
        }
        travel.travelers.insert(travelerRef)
        
        if travel.posibleTravelers.isEmpty && travel.canceledTravelers.isEmpty {
            travel.status = .on_road
        }
        
        try await travel.update(on: db)
    }
    
    func decline(traveler travelerRef: MongoRef, travel: GoTravel) async throws {
        _ = try await userService.select(id: travelerRef.id)
        if travel.posibleTravelers.remove(travelerRef) == nil {
            throw Abort(.badGateway, reason: "estás tratando de añadir a un usuario que no es parte del viaje")
        }
        travel.canceledTravelers.insert(travelerRef)
        
        try await travel.update(on: db)
    }
}
