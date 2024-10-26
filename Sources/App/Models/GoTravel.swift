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
    var meetingPoint: Place?
    
    @Field(key: "destination")
    var destination: Place
    
    @Field(key: "group_leader")
    var groupLeader: MongoRef //GoUser
    
    @Field(key: "travelers")
    var travelers: [MongoRef] //GoUser[]
    
    @Field(key: "meeting_date")
    var meetingDate: Date?
    
    @Field(key: "arrival_date")
    var arrivalDate: Date?
    
    @Field(key: "transport_service")
    var transport_service: TransportServices?
    
    //@Field(key: "status")
    //var status: TravelStatus
    
}
