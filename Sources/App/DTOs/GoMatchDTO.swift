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
    var leader: GoUserDTO
    var members: [GoUserDTO]
    var groupLength: Int
    var destination: Place
    var transport: TransportServices
    var status: GoMatch.Status
    var request: [GoUserDTO]
}

extension GoMatchDTO {
    func toModel() -> GoMatch {
        GoMatch(
            id: self.id,
            leader: MongoRef(id: self.leader.id!),
            members: Set(self.members.map {
                GoMember(user: MongoRef(id: $0.id!))
            }),
            requirements: nil,
            groupLength: self.groupLength,
            destination: self.destination,
            transport: self.transport,
            status: self.status,
            requests: self.request.map {
                MongoRef(id: $0.id!)
            })
    }
}

extension GoMatch {
    func toDTO(db: any Database) async throws -> GoMatchDTO {
        let userService = UserService(database: db)
        
        guard let leader = try? await userService.select(id: self.leader.id) else {
            throw Abort(.badRequest, reason: "leader no pudo ser encontrado")
        }
        
        var members: [GoUserDTO] = []
        for m in self.members {
            guard let savedMember = try? await userService.select(id: m.user.id) else {
                throw Abort(.badGateway, reason: "member no pudo ser encontrado")
            }
            members.append(savedMember.toDTO())
        }
        
        let requests: [GoUserDTO] = []
        for r in self.requests {
            guard let savedRequest = try? await userService.select(id: r.id) else {
                throw Abort(.badGateway, reason: "member no pudo ser encontrado")
            }
            members.append(savedRequest.toDTO())
        }
        
        return GoMatchDTO(
            id: self.id,
            leader: leader.toDTO(),
            members: members,
            groupLength: self.groupLength,
            destination: self.destination,
            transport: self.transport,
            status: self.status,
            request: requests)
    }
}

struct GoUserMatchable: Content {
    var matchId: UUID?
    var user: MongoRef
    var currentUbication: Place
    var destination: Place
    var groupLength: Int
}

struct GoMatchFinalized: Content {
    var user: MongoRef
    var match: MongoRef
}

struct GoMatchPost: Content {
    var leader: GoUserMatchable
    var transport: TransportServices
}

extension GoMatchPost {
    func toModel() -> GoMatch {
        GoMatch(
            leader: MongoRef(id: leader.user.id),
            members: [],
            groupLength: self.leader.groupLength,
            destination: self.leader.destination,
            transport: self.transport,
            status: .processing,
            requests: [])
    }
}
