//
//  GoPersonalProperties.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 24/10/24.
//

import Vapor
import Fluent

final class GoPersonalProperties: Fields, @unchecked Sendable {
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "lastname")
    var lastname: String
    
    @Field(key: "sex")
    var sex: String
    
    @Field(key: "gender")
    var gender: Gender
    
    @Field(key: "nationality")
    var nationality: String
    
    @Field(key: "birthday")
    var birthday: Date
    
    @Field(key: "age")
    var age: Int
    
    @Field(key: "emergency_contact")
    var emergencyContact: [GoContact]
}
