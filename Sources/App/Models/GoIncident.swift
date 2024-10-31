//
//  GoIncident.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 31/10/24.
//

import Vapor
import Fluent

final class GoIncident: Fields, @unchecked Sendable, Content {
    
    @Field(key: "happened_on")
    var happenedOn: Date
    
    @Field(key: "detected_by")
    var detectedBy: Detecters
    
    @Field(key: "affected")
    var affected: MongoRef //GoUser
    
    @Field(key: "on_travel")
    var onTravel: MongoRef //GoTravel
    
    enum Detecters: String, Content {
        case siri
        case user
        case gomigo_ia
    }
}
