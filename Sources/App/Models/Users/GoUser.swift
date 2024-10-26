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
    var currentUbication: Place?
    
    @Field(key: "online")
    var online: Bool
    
    @Field(key: "matching")
    var matching: Bool
    
    @Field(key: "friends")
    var friends: [MongoRef] //GoUser
    
    init() { }
    
    init(id: UUID? = nil, nickname: String, password: String, icon: Data? = nil, properties: GoPersonalProperties, files: GoFilesId, travels: [MongoRef], preferences: GoPreferences, stadistics: GoStadistics, score: Float, description: String, contact: GoContact, currentUbication: Place? = nil, online: Bool, matching: Bool, friends: [MongoRef]) {
        self.id = id
        self.nickname = nickname
        self.password = password
        self.icon = icon
        self.properties = properties
        self.files = files
        self.travels = travels
        self.preferences = preferences
        self.stadistics = stadistics
        self.score = score
        self.description = description
        self.contact = contact
        self.currentUbication = currentUbication
        self.online = online
        self.matching = matching
        self.friends = friends
    }
}

extension GoUser {
    
    func match(with user: GoUser) -> Bool {
        let userAgeRange = AgeRange.range(birthday: user.properties.birthday)!
        
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
