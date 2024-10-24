//
//  Document.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 24/10/24.
//

import Vapor
import Fluent

enum Documents: String {
    case user = "users"
    case match = "matches"
}

final class MongoRef: Fields, @unchecked Sendable, Content {
    
    @Field(key: "id")
    var id: UUID
    
    init() { }
    
    init(id: UUID) {
        self.id = id
    }
}
