//
//  GoFiles.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 24/10/24.
//

import Vapor
import Fluent

final class GoFilesId: Fields, @unchecked Sendable {
    
    @Field(key: "curp")
    var curp: String
    
    @Field(key: "face_photo")
    var facePhoto: Data?
    
    @Field(key: "front_personal_id")
    var frontPersonalId: Data?
    
    @Field(key: "back_personal_id")
    var backPersonalId: Data?
}
