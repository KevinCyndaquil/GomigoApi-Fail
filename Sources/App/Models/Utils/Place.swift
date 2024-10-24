//
//  Place.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 24/10/24.
//

import Vapor
import Fluent

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
}

extension Place {
    
    func toH3Index() -> H3Index {
        H3Index(coordinate: H3Coordinate(lat: latitude, lon: longitude),
                resolution: Place.h3Resolution)
    }
    
    func distance(to: Place) -> Double {
        return 0;
    }
}
