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
    static let schema: String = Documents.match.rawValue
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "poster")
    var poster: MongoRef //GoUser
    
    @Field(key: "current_ubication")
    var currentUbication: Place
    
    @Field(key: "destination")
    var destination: Place
    
    @Field(key: "travel")
    var travel: GoTravel?
    
    @Field(key: "group_length")
    var groupLength: Int
    
    @Field(key: "status")
    var status: Status
    
    @Field(key: "viewers")
    var viewers: [MongoRef] //GoUser
    
    @Field(key: "link_id")
    var linkId: UUID?
    
    @Field(key: "linked_users")
    var linkedUsers: Int
    
    init() { }
    
    init(id: UUID? = nil,
         poster: MongoRef,
         currentUbication: Place,
         destination: Place,
         travel: GoTravel? = nil,
         groupLength: Int,
         status: Status,
         viewers: [MongoRef],
         linkId: UUID? = nil){
        self.id = id
        self.poster = poster
        self.currentUbication = currentUbication
        self.destination = destination
        self.travel = travel
        self.groupLength = groupLength
        self.status = status
        self.viewers = viewers
        self.linkId = linkId
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
    
    func nearest(from matches: [GoMatch]) -> [GoMatch] {
        let currentH3Index = currentUbication.toH3Index()
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
        
        return nearestMatches
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
