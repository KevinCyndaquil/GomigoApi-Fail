//
//  GoStadistics.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 26/10/24.
//

import Vapor
import Fluent

final class GoStadistics: Fields, @unchecked Sendable, Content {
    
    @Field(key: "walked_kilometers")
    var walkedKilometers: Double
    
    @Field(key: "visited_cities")
    var visitedCities: Int
    
    @Field(key: "archivements")
    var archivements: Set<GoEarnArchivement>
}
