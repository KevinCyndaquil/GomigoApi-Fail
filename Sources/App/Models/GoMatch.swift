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
    var members: Set<GoMember> //GoMember
    
    @Field(key: "requirements")
    var requirements: GoPreferences?
    
    @Field(key: "group_length")
    var groupLength: Int
    
    @Field(key: "destination")
    var destination: Place
    
    @Field(key: "transport")
    var transport: TransportServices
    
    @Field(key: "status")
    var status: Status
    
    @Field(key: "requests")
    var requests: [MongoRef] //REF
    
    init() { }
    
    init(id: UUID? = nil, leader: MongoRef, members: Set<GoMember>, requirements: GoPreferences? = nil, groupLength: Int, destination: Place, transport: TransportServices, status: Status, requests: [MongoRef]) {
        self.id = id
        self.leader = leader
        self.members = members
        self.requirements = requirements
        self.groupLength = groupLength
        self.destination = destination
        self.transport = transport
        self.status = status
        self.requests = requests
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
        //let minDistance = Int32.max
        
        var places = users.map {
            $0.currentUbication!
        }
        places.append(request.currentUbication)
        
        for p in places {
            print("p(lat:", p.latitude, " lon:", p.longitude, ")")
        }
        
        let meetingPoint = Place.calculateMeetingPoint(people: places)
        
        print("meeting point lat:", meetingPoint.latitude, " lon:", meetingPoint.longitude)
        
        let h3Index = meetingPoint.toH3Index()
        let distance = h3Distance(currentH3Index.value, h3Index.value)
        
        print("current h3 distance ", distance)
        
        return distance <= 5
    }
    
    func nearest(from matches: [GoMatch]) -> [GoMatch] {
        /*let currentH3Index = currentUbication.toH3Index()
        var nearestMatches: [GoMatch] = []
        var minDistance = Int32.max
        
        for match in matches {
            let h3Index = match.currentUbication.toH3Index()
            let distance = h3Distance(currentH3Index.value, h3Index.value)
            
            if (distance == minDistance) {
                nearestMatches.append(match)
            }
            
            print("current distance " + String(distance))
                
            if distance >= 0 && distance < minDistance {
                minDistance = distance
                nearestMatches = [match]
            }
        }
        
        return nearestMatches*/
        return []
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
