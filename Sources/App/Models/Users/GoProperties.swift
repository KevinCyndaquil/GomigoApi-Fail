//
//  GoPersonalProperties.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 24/10/24.
//

import Vapor
import Fluent

final class GoProperties: Fields, @unchecked Sendable, Content {
    
    @Field(key: "sex")
    var sex: Sex
    
    @Field(key: "gender")
    var gender: Gender
    
    @Field(key: "nationality")
    var nationality: String
    
    init() { }
    
    init(sex: Sex, gender: Gender, nationality: String) {
        self.sex = sex
        self.gender = gender
        self.nationality = nationality
    }
}
