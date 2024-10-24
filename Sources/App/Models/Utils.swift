//
//  Utils.swift
//  GoMigoModel
//
//  Created by ADMIN UNACH on 15/10/24.
//

import Vapor
import Fluent
import struct Foundation.UUID

import Ch3

enum DbDocuments: String {
    case users = "users"
    case matchs = "matches"
}

final class DBRef: Fields, @unchecked Sendable, Content {
    @Field(key: "id")
    var id: UUID
    
    init() { }
    
    init(id: UUID) {
        self.id = id
    }
}

enum Gender: String, Content {
    case male
    case female
    case no_binary
}

enum AgeRange: String, Content {
    case childhood
    case puberty
    case teenager
    case young_adult
    case elder
}

enum TravelStatus: String, Content {
    case finished
    case canceled
    case waiting_travelers
    case going_to_destination
    case with_incidents
}

enum TransportServices: String, Content {
    case walk
    case uber
    case taxi
    case public_transport
}

final class Place: Fields, @unchecked Sendable, Content {
    static let h3Resolution: Int32 = 10
    
    @Field(key: "country")
    var country: String
    
    @Field(key: "city")
    var city: String
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "type")
    var type: String
    
    @Field(key: "latitude")
    var latitude: Double
    
    @Field(key: "longitude")
    var longitude: Double
    
    func toH3Index() -> H3Index {
        H3Index(coordinate: H3Coordinate(lat: latitude, lon: longitude),
                resolution: Place.h3Resolution)
    }
}

extension H3Index {
    internal init(place: Place, resolution: Int32) {
        self.init(coordinate: H3Coordinate(lat: place.latitude, lon: place.longitude), resolution: resolution)
    }
}

struct Credentials: Content {
    var username: String
    var password: String
}
