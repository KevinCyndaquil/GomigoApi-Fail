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
    var leader: MongoRef? // GoUser
    
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
    
    init(id: UUID? = nil, leader: MongoRef? = nil, members: Set<GoMember>, requirements: GoPreferences? = nil, groupLength: Int, destination: Place, transport: TransportServices, status: Status, requests: [MongoRef]) {
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
        case finished = 0
        case finished_by_other = 1
        case processing = 2
        case waiting = 3
        case not_matched = 4
        case matched = 5
        case linked = 6
    }
}

extension GoMatch {
    
    static func nearest(from request: GoUserMatchable, to matchList: [GoUser]) -> Bool {
        let currentH3Index = request.currentUbication.toH3Index()
        var minDistance = Int32.max
        
        for match in matchList {
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
        
        return nearestMatches
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
