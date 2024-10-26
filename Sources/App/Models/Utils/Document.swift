//
//  Document.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 24/10/24.
//

import Vapor
import Fluent

final class MongoRef: Fields, @unchecked Sendable, Content {
    
    @Field(key: "id")
    var id: UUID
    
    init() { }
    
    init(from model: any Model) throws {
        self.id = model.id as! UUID
    }
    
    init(id: UUID) {
        self.id = id
    }
}

extension MongoRef: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MongoRef, rhs: MongoRef) -> Bool {
        lhs.id == rhs.id
    }
    
}
