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
    
    init() { }
    
    init(walkedKilometers: Double, visitedCities: Int, archivements: Set<GoEarnArchivement>) {
        self.walkedKilometers = walkedKilometers
        self.visitedCities = visitedCities
        self.archivements = archivements
    }
    
    static let zero = GoStadistics(walkedKilometers: 0, visitedCities: 0, archivements: [])
}
