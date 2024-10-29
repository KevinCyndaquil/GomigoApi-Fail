//
//  GoUser.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 24/10/24.
//

import Vapor
import Fluent

final class GoUser: Model, @unchecked Sendable, Content {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "lastname")
    var lastname: String
    
    @Field(key: "nickname")
    var nickname: String
    
    @Field(key: "password")
    var password: String
    
    @Field(key: "icon")
    var icon: Data?
    
    @Field(key: "properties")
    var properties: GoProperties
    
    @Field(key: "domicilie")
    var domicilie: GoDomicilie

    @Field(key: "files")
    var files: GoFilesId
    
    @Field(key: "travels")
    var travels: [MongoRef] //GoTravel
    
    @Field(key: "preferences")
    var preferences: GoPreferences
    
    @Field(key: "stadistics")
    var stadistics: GoStadistics
    
    @Field(key: "score")
    var score: Float
    
    @Field(key: "description")
    var description: String
    
    @Field(key: "birthday")
    var birthday: Date
    
    @Field(key: "contact")
    var contact: GoContact
    
    @Field(key: "current_ubication")
    var currentUbication: Place?
    
    @Field(key: "online")
    var online: Bool
    
    @Field(key: "friends")
    var friends: [MongoRef] //GoUser
    
    @Field(key: "emergency_contact")
    var emergencyContact: [GoContact]
    
    init() { }
    
    init(id: UUID? = nil, name: String, lastname: String, nickname: String, password: String, icon: Data? = nil, properties: GoProperties, domicilie: GoDomicilie, files: GoFilesId, travels: [MongoRef], preferences: GoPreferences, stadistics: GoStadistics, score: Float, description: String, birthday: Date, contact: GoContact, currentUbication: Place? = nil, online: Bool, friends: [MongoRef], emergencyContact: [GoContact]) {
        self.id = id
        self.name = name
        self.lastname = lastname
        self.nickname = nickname
        self.password = password
        self.icon = icon
        self.properties = properties
        self.domicilie = domicilie
        self.files = files
        self.travels = travels
        self.preferences = preferences
        self.stadistics = stadistics
        self.score = score
        self.description = description
        self.birthday = birthday
        self.contact = contact
        self.currentUbication = currentUbication
        self.online = online
        self.friends = friends
        self.emergencyContact = emergencyContact
    }
}

extension GoUser {
    
    func areMatching(with preferences: GoProperties) -> Bool {
        let ageRange = AgeRange.range(birthday: self.birthday)!
        
        return self.preferences.matchingSex.contains(preferences.sex)
        &&
        self.preferences.matchingGender.contains(preferences.gender)
        &&
        self.preferences.ageRange.contains(ageRange)
        &&
        (self.preferences.matchForeigns ? self.properties.nationality == preferences.nationality : true)
    }
}
