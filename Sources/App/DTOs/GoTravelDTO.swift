//
//  GoTravelDTO.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 29/10/24.
//

import Vapor
import Fluent

struct GoTravelDTO: Content {
    var id: UUID
    var meetingPoint: Place
    var destination: Place
    var travelers: [GoUserDTO]
    var meetingDate: Date?
    var arrivalDate: Date?
    var transport: TransportServices
}

extension GoTravel {
    func toDTO(db: any Database) async throws -> GoTravelDTO {
        let userService = try GoUserService(on: db)
        
        var travelers: [GoUserDTO] = []
        for traveler in self.travelers {
            travelers.append(try await userService.select(id: traveler.id).toDTO())
        }
        
        return GoTravelDTO(
            id: self.id!,
            meetingPoint: self.meetingPoint,
            destination: self.destination,
            travelers: travelers,
            transport: self.transport)
    }
}

struct GoTravelResponse: Content {
    var travelId: MongoRef
    var fromUser: MongoRef
}
