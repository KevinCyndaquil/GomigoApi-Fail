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
    
    @Field(key: "personal_id")
    var personalId: Data?
}
