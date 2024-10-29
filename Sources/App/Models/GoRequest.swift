//
//  GoRequest.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 28/10/24.
//

import Vapor
import Fluent

final class GoRequest: Fields, @unchecked Sendable, Content {
    
    @Field(key: "id")
    var id: UUID
    
    @Field(key: "user")
    var user: MongoRef
    
    @Field(key: "response")
    var response: Responses
    
    enum Responses: String, Content {
        case waiting
        case accepted
        case declined
        case not_matched
    }
    
    init() { }
    
    init(userId: UUID) {
        self.id = UUID()
        self.user = MongoRef(id: userId)
        self.response = .waiting
    }
}

extension GoRequest: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: GoRequest, rhs: GoRequest) -> Bool {
        lhs.id == rhs.id
    }
}
