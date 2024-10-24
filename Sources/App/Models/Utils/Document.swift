//
//  Document.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 24/10/24.
//

import Vapor
import Fluent

enum DbDocuments: String {
    case users = "users"
    case matchs = "matches"
}

final class DBRef: Fields, @unchecked Sendable, Content {
    @Field(key: "id")
    var id: UUID
    
    init() { }
    
    init(id: UUID) {
        self.id = id
    }
}
