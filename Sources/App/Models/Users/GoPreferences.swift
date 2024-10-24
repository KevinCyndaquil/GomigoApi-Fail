//
//  GoPreferences.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 24/10/24.
//

import Vapor
import Fluent

final class GoPreferences: Fields, @unchecked Sendable {
    
    @Field(key: "match_with_sex")
    var matchWithSex: [String]
    
    @Field(key: "match_with_gender")
    var matchWithGender: [Gender]
    
    @Field(key: "match_age")
    var matchAge: [AgeRange]
    
    @Field(key: "emergency_contact")
    var emergencyContact: [GoContact]
    
    @Field(key: "match_foreigns")
    var matchForeigns: Bool
    
    @Field(key: "match_other_nationalities")
    var matchOtherNationalities: Bool
    
    init() { }
    
    init(matchWithSex: [String], matchWithGender: [Gender], emergencyContact: [GoContact], matchForeigns: Bool, matchOtherNationalities: Bool) {
        self.matchWithSex = matchWithSex
        self.matchWithGender = matchWithGender
        self.emergencyContact = emergencyContact
        self.matchForeigns = matchForeigns
        self.matchOtherNationalities = matchOtherNationalities
    }
    
    static let def_preference = GoPreferences(
        matchWithSex: ["male", "female"],
        matchWithGender: [.female, .male, .no_binary],
        emergencyContact: [], matchForeigns: true,
        matchOtherNationalities: true)
}
