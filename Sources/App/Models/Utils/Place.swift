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
    
    init() { }
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension Place {
    private static func toCartesian(coor: Place) -> (x: Double, y: Double, z: Double) {
        let a = coor.latitude * .pi / 180
        let b = coor.longitude * .pi / 180
        let x = cos(a) * cos(b)
        let y = cos(a) * sin(b)
        let z = sin(b)
        return (x, y, z)
    }
    
    static func calculateMeetingPoint(people: [Place]) -> Place {
        var coor = (x: 0.0, y: 0.0, z: 0.0)
        
        for person in people {
            let (cartX, cartY, cartZ) = toCartesian(coor: person)
            coor.x += cartX
            coor.y += cartY
            coor.z += cartZ
        }
        
        let total = Double(people.count)
        coor.x /= total
        coor.y /= total
        coor.z /= total
        
        let lon = atan2(coor.y, coor.x)
        let hyp = sqrt(pow(coor.x, 2) + pow(coor.y, 2))
        let lat = atan2(coor.z, hyp)
        
        return Place(latitude: lat * 180 / .pi, longitude: lon * 180 / .pi)
    }
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
        
        let a = pow(sin(dLat / 2), 2) + cos(coorRad1[0]) * cos(coorRad2[0]) * pow(sin(dLon / 2), 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        let earthRadius: Double = 6371000
        
        return earthRadius * c;
    }
}
