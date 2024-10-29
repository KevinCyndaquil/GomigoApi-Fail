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
    var travelers: [MongoRef] //GoUser[]
    
    @Field(key: "meeting_date")
    var meetingDate: Date?
    
    @Field(key: "arrival_date")
    var arrivalDate: Date?
    
    @Field(key: "transport_service")
    var transport: TransportServices

    @Field(key: "status")
    var status: Status
    
    @Field(key: "posible_travelers")
    var posibleTravelers: [MongoRef]
    
    @Field(key: "canceled_travelers")
    var canceledTravelers: [MongoRef]
    
    enum Status: String, Content {
        case waiting_confirmation
        case on_road
        case at_meeting_point
        case finished
        case canceled
    }
}
