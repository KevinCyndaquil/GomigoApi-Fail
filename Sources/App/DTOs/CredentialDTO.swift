//
//  CredentialDTO.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 24/10/24.
//

import Vapor
import Fluent

struct Credentials: Content {
    var username: String
    var password: String
}
