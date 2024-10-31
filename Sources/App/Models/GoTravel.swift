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
    
    @Field(key: "travelers")
    var travelers: Set<MongoRef> //GoUser[]
    
    @Field(key: "meeting_date")
    var meetingDate: Date?
    
    @Field(key: "arrival_date")
    var arrivalDate: Date?
    
    @Field(key: "transport_service")
    var transport: TransportServices

    @Field(key: "status")
    var status: Status
    
    init() { }
    
    init(from match: GoMatch) {
        self.meetingPoint = match.currentMeetingPoint!
        self.destination = match.destination
        self.travelers = Set([match.leader]).union(match.members)
        self.transport = match.transport
        self.status = .on_road
    }
    
    init(id: UUID? = nil, meetingPoint: Place, destination: Place, travelers: Set<MongoRef>, meetingDate: Date? = nil, arrivalDate: Date? = nil, transport: TransportServices, status: Status) {
        self.id = id
        self.meetingPoint = meetingPoint
        self.destination = destination
        self.travelers = travelers
        self.meetingDate = meetingDate
        self.arrivalDate = arrivalDate
        self.transport = transport
        self.status = status
    }
    
    enum Status: String, Content {
        case on_road
        case at_meeting_point
        case finished
        case canceled
    }
}
