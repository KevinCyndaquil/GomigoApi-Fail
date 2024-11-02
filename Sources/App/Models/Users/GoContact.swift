//
//  GoContact.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 24/10/24.
//

import Vapor
import Fluent

final class GoContact: Fields, @unchecked Sendable {
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "relationship")
    var relantionship: String
    
    @Field(key: "phone_number")
    var phoneNumber: String
    
    @Field(key: "email_address")
    var emailAddress: String
}
