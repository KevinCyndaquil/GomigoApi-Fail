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

final class GoUser: Model, @unchecked Sendable, Content {
    static let schema = DbDocuments.users.rawValue
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "nickname")
    var nickname: String
    
    @Field(key: "password")
    var password: String
    
    @Field(key: "icon")
    var icon: Data?
    
    @Field(key: "score")
    var score: Float
    
    @Field(key: "description")
    var description: String
    
    @Field(key: "files")
    var files: GoFilesId
    
    @Field(key: "properties")
    var properties: GoPersonalProperties
    
    @Field(key: "preferences")
    var preferences: GoPreferences
    
    @Field(key: "contact")
    var contact: GoContact
    
    @Field(key: "friends")
    var friends: [DBRef] //GoUser
    
    
    init() { }
    
    init(id: UUID? = nil,
         nickname: String,
         password: String,
         icon: Data? = nil,
         score: Float,
         description: String,
         files: GoFilesId,
         properties: GoPersonalProperties,
         preferences: GoPreferences,
         contact: GoContact,
         friends: [DBRef]) {
        self.id = id
        self.nickname = nickname
        self.password = password
        self.icon = icon
        self.score = score
        self.description = description
        self.files = files
        self.properties = properties
        self.preferences = preferences
        self.contact = contact
        self.friends = friends
    }
    
    
    final class Archivement: Fields, @unchecked Sendable {
        
        @Field(key: "archivement")
        var archivement: GoArchivement
        
        @Field(key: "obtained")
        var obtained: Date
        
        @Field(key: "progress")
        var progress: Float
    }
}


final class GoPersonalProperties: Fields, @unchecked Sendable {
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "lastname")
    var lastname: String
    
    @Field(key: "sex")
    var sex: String
    
    @Field(key: "gender")
    var gender: Gender
    
    @Field(key: "nationality")
    var nationality: String
    
    @Field(key: "birthday")
    var birthday: Date
    
    @Field(key: "age")
    var age: Int
}


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

