//
//  GoDomicilie.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 28/10/24.
//

import Vapor
import Fluent

final class GoDomicilie: Fields, @unchecked Sendable, Content {
    
    @Field(key: "street")
    var street: String
    
    @Field(key: "inside_number")
    var insideNumber: String
    
    @Field(key: "country")
    var country: String
    
    @Field(key: "state")
    var state: String
    
    @Field(key: "town")
    var town: String
    
    @Field(key: "postal_code")
    var postalCode: String
    
    @Field(key: "colony")
    var colony: String
    
    init() { }
    
    init(street: String, insideNumber: String, country: String, state: String, town: String, postalCode: String, colony: String) {
        self.street = street
        self.insideNumber = insideNumber
        self.country = country
        self.state = state
        self.town = town
        self.postalCode = postalCode
        self.colony = colony
    }
}
