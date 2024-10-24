//
//  User.swift
//  GoMigoModel
//
//  Created by ADMIN UNACH on 15/10/24.
//

import Vapor
import Fluent
import struct Foundation.UUID
import JWT




final class GoFilesId: Fields, @unchecked Sendable {
    
    @Field(key: "curp")
    var curp: String
    
    @Field(key: "face_photo")
    var facePhoto: Data?
    
    @Field(key: "personal_id")
    var personalId: Data?
}


final class GoContact: Fields, @unchecked Sendable {
    
    @Field(key: "name")
    var name: String?
    
    @Field(key: "phone_number")
    var phoneNumber: String
    
    @Field(key: "email_address")
    var emailAddress: String
}


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


final class GoArchivement: Model, @unchecked Sendable {
    static let schema = "archivements"
    
    @Field(key: .id)
    var id: UUID?
    
    @Field(key: "icon")
    var icon: String
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "description")
    var description: String
    
    @Field(key: "progress_needed")
    var progressNeeded: Float
    
    init() { }
    
    init(id: UUID? = nil, icon: String, name: String, description: String, progressNeeded: Float) {
        self.id = id
        self.icon = icon
        self.name = name
        self.description = description
        self.progressNeeded = progressNeeded
    }
}

