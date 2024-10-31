//
//  MatchDTO.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 21/10/24.
//

import Vapor
import Fluent

struct GoMatchDTO: Content {
    var id: UUID
    var leader: GoUserDTO
    var members: [GoUserDTO]
    var groupLength: Int
    var destination: Place
    var transport: TransportServices
    var status: GoMatch.Status
    var request: [GoUserDTO]
    var travel: GoTravel?
}

extension GoMatch {
    func toDTO(db: any Database) async throws -> GoMatchDTO {
        let userService = try GoUserService(on: db)
        
        guard let leader = try? await userService.select(id: self.leader.id) else {
            throw Abort(.badRequest, reason: "leader no pudo ser encontrado")
        }
        
        var members: [GoUserDTO] = []
        for m in self.members {
            guard let savedMember = try? await userService.select(id: m.id) else {
                throw Abort(.badGateway, reason: "member no pudo ser encontrado")
            }
            members.append(savedMember.toDTO())
        }
        
        var requests: [GoUserDTO] = []
        for r in self.requests {
            guard let savedRequest = try? await userService.select(id: r.id) else {
                throw Abort(.badGateway, reason: "member no pudo ser encontrado")
            }
            requests.append(savedRequest.toDTO())
        }
        
        return GoMatchDTO(
            id: self.id!,
            leader: leader.toDTO(),
            members: members,
            groupLength: self.groupLength,
            destination: self.destination,
            transport: self.transport,
            status: self.status,
            request: requests,
            travel: nil)
    }
}

struct GoUserMatchable: Content {
    var matchId: MongoRef?
    var userFindingMatches: MongoRef
    var currentUbication: Place
    var destination: Place
    var groupLength: Int
    var transport: TransportServices
}

extension GoUserMatchable {
    func toModel() -> GoMatch {
        GoMatch(
            leader: self.userFindingMatches,
            members: [],
            requests: [],
            groupLength: self.groupLength,
            destination: self.destination,
            transport: self.transport,
            status: .processing,
            creationDate: Date.now)
    }
}

struct GoMatchResponse: Content {
    var matchId: MongoRef
    var fromUser: MongoRef
    var replyToUser: MongoRef
}

struct GoMatchRequest: Content {
    var matchId: MongoRef
    var requesterId: MongoRef
}

struct GoGetoutMatch: Content {
    var matchId: MongoRef
    var requesterId: MongoRef?
    var userToGetout: MongoRef
}
