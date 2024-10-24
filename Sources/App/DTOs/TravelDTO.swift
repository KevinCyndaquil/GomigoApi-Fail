//
//  MatchDTO.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 21/10/24.
//

import Vapor
import Fluent

struct GoMatchDTO: Content {
    var id: UUID?
    var poster: GoUserDTO
    var currentUbication: Place
    var destination: Place
    //var travel: GoTravel?
    var groupLength: Int
    var status: GoMatch.Status
    var viewers: [GoUserDTO]
}

extension GoMatchDTO {
    func toModel() -> GoMatch {
        GoMatch(id: id,
                poster: MongoRef(id: self.poster.id!),
                currentUbication: self.currentUbication,
                destination: self.destination,
                groupLength: self.groupLength,
                status: self.status,
                viewers: self.viewers.compactMap { $0.id }.map { MongoRef(id: $0) }
        )
    }
}

extension GoMatch {
    func toDTO(db: any Database) async throws -> GoMatchDTO {
        let userService = UserService(database: db)
        
        let poster = try await userService.select(id: self.poster.id)!
        
        var viewers: [GoUserDTO] = []
        for v in self.viewers {
            try await viewers.append(userService.select(id: v.id)!)
        }
        
        return GoMatchDTO(
            id: self.id,
            poster: poster,
            currentUbication: self.currentUbication,
            destination: self.destination,
            groupLength: self.groupLength,
            status: self.status,
            viewers: viewers)
    }
}

struct GoMatchPost: Content {
    var poster: MongoRef
    var currentUbication: Place
    var destination: Place
    var groupLength: Int
}

extension GoMatchPost {
    func toModel() -> GoMatch {
        GoMatch(
            poster: self.poster,
            currentUbication: self.currentUbication,
            destination: self.destination,
            groupLength: self.groupLength,
            status: .processing,
            viewers: [])
    }
}
