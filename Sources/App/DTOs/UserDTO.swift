//
//  UserDTO.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 18/10/24.
//

import Vapor
import Fluent

struct GoUserDTO: Content {
    var id: UUID?
    var nickname: String //
    var password: String //
    var icon: Data?
    var score: Float
    var description: String
    //var files: GoFilesId //
    //var properties: GoPersonalProperties //
    //var preferences: GoPreferences
    //var contact: GoContact
    //var friends: [GoUserDTO]
}

/*extension GoUserDTO {
    func toModel() -> GoUser {
        GoUser(id: self.id,
               nickname: self.nickname,
               password: self.password,
               score: self.score,
               description: self.description)
    }
}*/

extension GoUser {
    func toDTO() -> GoUserDTO {
        GoUserDTO(
            id: self.id,
            nickname: self.nickname,
            password: self.password,
            score: self.score,
            description: self.description)
    }
}

struct GoUserPost: Content {
    var nickname: String
    var password: String
    var files: GoFilesId
    var properties: GoPersonalProperties
    var contact: GoContact
}

extension GoUserPost {
    func toModel() -> GoUser {
        GoUser(
            nickname: self.nickname,
            password: self.password,
            score: 0,
            description: "sin descripcion",
            files: self.files,
            properties: self.properties,
            preferences: GoPreferences.def_preference,
            contact: self.contact,
            friends: [])
    }
}
