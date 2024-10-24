//
//  GoUser.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 24/10/24.
//

import Vapor
import Fluent

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
