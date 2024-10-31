//
//  GoMatch.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 24/10/24.
//

import Vapor
import Fluent

import Ch3

final class GoMatch: Model, @unchecked Sendable, Content {
    static let schema: String = "matches"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "leader")
    var leader: MongoRef // GoUser
    
    @Field(key: "members")
    var members: Set<MongoRef> //GoUser
    
    @Field(key: "requests")
    var requests: Set<MongoRef> //GoUser
    
    @Field(key: "group_length")
    var groupLength: Int
    
    @Field(key: "destination")
    var destination: Place
    
    @Field(key: "transport")
    var transport: TransportServices
    
    @Field(key: "status")
    var status: Status
    
    @Field(key: "travel")
    var travel: MongoRef?
    
    @Field(key: "current_meeting_point")
    var currentMeetingPoint: Place?
    
    init() {
        self.travel = nil
        self.currentMeetingPoint = nil
    }
    
    init(id: UUID? = nil, leader: MongoRef, members: Set<MongoRef>, requests: Set<MongoRef>, groupLength: Int, destination: Place, transport: TransportServices, status: Status) {
        self.id = id
        self.leader = leader
        self.members = members
        self.requests = requests
        self.groupLength = groupLength
        self.destination = destination
        self.transport = transport
        self.status = status
        self.travel = nil
        self.currentMeetingPoint = nil
    }
    
    enum Status: Int, Content {
        case processing = 0
        case canceled = 1
        case matched = 2
        case finalized = 3
    }
}


extension GoMatch {
    
    static func nearest(from request: GoUserMatchable, to users: [GoUser]) -> Bool {
        let currentH3Index = request.currentUbication.toH3Index()
        
        var places = users.map { $0.currentUbication! }
        places.append(request.currentUbication)
        
        for p in places {
            print("p(lat:", p.latitude, " lon:", p.longitude, ")")
        }
        
        let meetingPoint = Place.calculateMeetingPoint(of: places)
        
        print("meeting point lat:", meetingPoint.latitude, " lon:", meetingPoint.longitude)
        
        let h3Index = meetingPoint.toH3Index()
        let distance = h3Distance(currentH3Index.value, h3Index.value)
        
        print("current h3 distance ", distance)
        
        return distance <= 5
    }
    
    static func nearest(from point: Place, to users: [GoUser]) -> Bool {
        let currentH3Index = point.toH3Index()
        
        var places = users.map { $0.currentUbication! }
        places.append(point)
        
        for p in places {
            print("p(lat:", p.latitude, " lon:", p.longitude, ")")
        }
        
        let meetingPoint = Place.calculateMeetingPoint(of: places)
        
        print("meeting point lat:", meetingPoint.latitude, " lon:", meetingPoint.longitude)
        
        let h3Index = meetingPoint.toH3Index()
        let distance = h3Distance(currentH3Index.value, h3Index.value)
        
        print("current h3 distance ", distance)
        
        return distance <= 5
    }
    
    /// We can know if a requester, can join a group based in their personal preferences and properties
    static func preferencesMatching(requester: GoUser, members: [GoUser]) -> Bool {
        members.reduce(true, {
            $0 && $1.areMatching(with: requester.properties)
        })
    }
    
    static func depureRequest(members: [GoUser], requests: [GoUser]) -> [GoUser] {
        return requests.filter {
            preferencesMatching(requester: $0, members: members)
        }
    }
}

extension GoMatch {
    
    func mustActive() throws -> GoMatch {
        if status == .canceled || status == .finalized {
            throw Abort(.badRequest, reason: "Match ya finalizado")
        }
        return self
    }
    
    func isCompleted() throws -> GoMatch {
        if groupLength == members.count + 1 {
            throw Abort(.badRequest, reason: "Grupo ya completado")
        }
        
        return self
    }
}

extension GoMatch: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: GoMatch, rhs: GoMatch) -> Bool {
        lhs.id == rhs.id
    }
}
