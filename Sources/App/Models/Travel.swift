//
//  Match.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 21/10/24.
//

import Vapor
import Fluent
import Foundation

import Ch3

final class GoTravel: Model, @unchecked Sendable, Content {
    static let schema = "travels"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "meeting_point")
    var meetingPoint: Place?
    
    @Field(key: "destination")
    var destination: Place
    
    @Field(key: "group_leader")
    var groupLeader: DBRef //GoUser
    
    @Field(key: "travelers")
    var travelers: [DBRef] //GoUser[]
    
    @Field(key: "meeting_date")
    var meetingDate: Date?
    
    @Field(key: "arrival_date")
    var arrivalDate: Date?
    
    @Field(key: "transport_service")
    var transport_service: TransportServices?
    
    @Field(key: "status")
    var status: TravelStatus
    
}

///This is the matcher object, and the flag to know when a user wants to travel.
///First, the local user sends this object to server, then, the server save it and starts to match when a nearby user match when the requeriments
final class GoMatch: Model, @unchecked Sendable, Content {
    static let schema: String = "matchs"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "poster")
    var poster: DBRef //GoUser
    
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
    var viewers: [DBRef] //GoUser
    
    init() { }
    
    init(id: UUID? = nil,
         poster: DBRef,
         currentUbication: Place,
         destination: Place,
         travel: GoTravel? = nil,
         groupLength: Int,
         status: Status,
         viewers: [DBRef]){
        self.id = id
        self.poster = poster
        self.currentUbication = currentUbication
        self.destination = destination
        self.travel = travel
        self.groupLength = groupLength
        self.status = status
        self.viewers = viewers
    }
    
    enum Status: String, Content {
        case processing
        case matched
        case waiting
        case not_matched
    }
    
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
