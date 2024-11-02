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
    var traveler: GoUserDTO
    var match: GoMatchDTO
    var meetingDate: Date?
    var arrivalDate: Date?
}

extension GoTravel {
    func toDTO(db: any Database) async throws -> GoTravelDTO {
        let userService = try GoUserService(on: db)
        let matchService = try GoMatchService(on: db)
        
        let traveler = try await userService
            .select(id: self.traveler.id)
            .toDTO()
        let match = try await matchService
            .select(id: self.match.id)
            .toDTO(db: db)
        
        return GoTravelDTO(
            id: self.id!,
            meetingPoint: self.meetingPoint,
            destination: self.destination,
            traveler: traveler,
            match: match)
    }
}

struct GoTravelRequest: Content {
    var travelId: MongoRef
    var fromUser: MongoRef
}
