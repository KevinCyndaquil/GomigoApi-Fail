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
    
    @Field(key: "nickname")
    var nickname: String
    
    @Field(key: "password")
    var password: String
    
    @Field(key: "icon")
    var icon: Data?
    
    @Field(key: "properties")
    var properties: GoPersonalProperties

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
    
    @Field(key: "contact")
    var contact: GoContact
    
    @Field(key: "current_ubication")
    var currentUbication: Place
    
    @Field(key: "online")
    var online: Bool
    
    @Field(key: "matching")
    var matching: Bool
    
    @Field(key: "friends")
    var friends: [MongoRef] //GoUser
    
    init() { }
    
    init(id: UUID? = nil, nickname: String, password: String, icon: Data? = nil, score: Float, description: String, files: GoFilesId, properties: GoPersonalProperties, preferences: GoPreferences, contact: GoContact, friends: [MongoRef], currentUbication: Place, online: Bool, matching: Bool, travels: [MongoRef]) {
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
        self.currentUbication = currentUbication
        self.online = online
        self.matching = matching
        self.travels = travels
    }
}

extension GoUser {
    
    func match(with user: GoUser) -> Bool {
        var userAgeRange = AgeRange.range(birthday: user.properties.birthday)!
        
        var wasMatch = preferences.matchingGender
                .contains(user.properties.gender) &&
            preferences.ageRange
                .contains(userAgeRange)
        
        if !preferences.matchForeigns {
            wasMatch = properties.nationality == user.properties.nationality
        }
        
        return wasMatch
    }
}
