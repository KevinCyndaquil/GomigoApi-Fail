//
//  Place.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 24/10/24.
//

import Vapor
import Fluent
import CoreLocation

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
        let coorRad1 = [
            self.latitude * .pi / 180,
            self.longitude * .pi / 180,
        ]
        let coorRad2 = [
            to.latitude * .pi / 180,
            to.longitude * .pi / 180,
        ]
        
        let dLat = coorRad2[0] - coorRad1[0]
        let dLon = coorRad2[1] - coorRad1[1]
        
        let a = pow(sin(dLat / 2), 2) + cos(coorRad1[0]) * cos(<#T##Double#>)
        
        return 0;
    }
}
