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
    var birthday: Date
    var icon: Data?
    var score: Float
    var description: String
}

extension GoUser {
    func toDTO() -> GoUserDTO {
        GoUserDTO(
            id: self.id,
            name: self.name,
            lastname: self.lastname,
            birthday: self.birthday,
            score: self.score,
            description: self.description)
    }
}

struct GoUserPost: Content {
    var name: String
    var lastname: String
    var password: String
    var files: GoFilesId
    var icon: Data?
    var properties: GoProperties
    var domicilie: GoDomicilie
    
    var facebook: String?
    var instagram: String?
    var twitter: String?
    var phoneNumber: String
    var emailAddress: String
    var birthday: Date
    
    var emergencyContact: [GoContact]
}

extension GoUserPost {
    func toModel() -> GoUser {
        GoUser(
            name: self.name,
            lastname: self.lastname,
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
            facebook: self.facebook,
            instagram: self.instagram,
            twitter: self.twitter,
            phoneNumber: self.phoneNumber,
            emailAddress: self.emailAddress,
            friends: [],
            emergencyContact: self.emergencyContact)
    }
}

struct GoUserUbication: Content {
    var id: UUID
    var currentUbication: Place
}
