//
//  GoTravel.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 24/10/24.
//


import Vapor
import Fluent

final class GoTravel: Model, @unchecked Sendable, Content {
    static let schema = "travels"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "meeting_point")
    var meetingPoint: Place
    
    @Field(key: "destination")
    var destination: Place
    
    @Field(key: "traveler")
    var traveler: MongoRef //GoUser
    
    @Field(key: "match")
    var match: MongoRef
    
    @Field(key: "meeting_date")
    var meetingDate: Date?
    
    @Field(key: "arrival_date")
    var arrivalDate: Date?

    @Field(key: "status")
    var status: Status
    
    init() { }
    
    init(from match: GoMatch, traveler: MongoRef) {
        self.meetingPoint = match.currentMeetingPoint!
        self.destination = match.destination
        self.traveler = traveler
        self.match = MongoRef(id: match.id!)
        self.status = .on_road
    }
    
    init(id: UUID? = nil, meetingPoint: Place, destination: Place, traveler: MongoRef, match: MongoRef, meetingDate: Date? = nil, arrivalDate: Date? = nil, status: Status) {
        self.id = id
        self.meetingPoint = meetingPoint
        self.destination = destination
        self.traveler = traveler
        self.match = match
        self.meetingDate = meetingDate
        self.arrivalDate = arrivalDate
        self.status = status
    }
    
    enum Status: String, Content {
        case on_road
        case at_meeting_point
        case finished
        case canceled
    }
}
