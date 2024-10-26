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
}

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
            properties: self.properties,
            files: self.files,
            travels: [],
            preferences: GoPreferences.common,
            stadistics: GoStadistics.zero,
            score: 0,
            description: "nada aqui",
            contact: self.contact,
            online: false,
            matching: false,
            friends: []
        )
    }
}

struct GoUserUbication: Content {
    var id: UUID
    var currentUbication: Place
}
