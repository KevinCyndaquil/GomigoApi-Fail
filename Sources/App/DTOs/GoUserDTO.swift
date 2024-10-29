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
    var name: String
    var lastname: String
    var nickname: String
    var birthday: Date
    var icon: Data?
    var score: Float
    var description: String
    var online: Bool
}

extension GoUser {
    func toDTO() -> GoUserDTO {
        GoUserDTO(
            id: self.id,
            name: self.name,
            lastname: self.lastname,
            nickname: self.nickname,
            birthday: self.birthday,
            score: self.score,
            description: self.description,
            online: self.online)
    }
}

struct GoUserPost: Content {
    var name: String
    var lastname: String
    var nickname: String
    var password: String
    var files: GoFilesId
    var properties: GoProperties
    var domicilie: GoDomicilie
    var contact: GoContact
    var birthday: Date
    var emergencyContact: [GoContact]
}

extension GoUserPost {
    func toModel() -> GoUser {
        GoUser(
            name: self.name,
            lastname: self.lastname,
            nickname: self.nickname,
            password: self.password,
            properties: self.properties,
            domicilie: self.domicilie,
            files: self.files,
            travels: [],
            preferences: GoPreferences.common,
            stadistics: GoStadistics.zero,
            score: 0,
            description: "sin descripción",
            birthday: self.birthday,
            contact: self.contact,
            online: false,
            friends: [],
            emergencyContact: self.emergencyContact)
    }
}

struct GoUserUbication: Content {
    var id: UUID
    var currentUbication: Place
}
