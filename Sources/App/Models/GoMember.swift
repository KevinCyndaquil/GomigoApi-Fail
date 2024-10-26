//
//  GoMember.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 26/10/24.
//

import Vapor
import Fluent

final class GoMember: Fields, @unchecked Sendable, Content {
    
    @Field(key: "user")
    var user: MongoRef
    
    @Field(key: "response")
    var response: String?
    
    init() { }
    
    init(from user: GoUser) {
        self.user = MongoRef(id: user.id!)
        self.response = nil
    }
    
    init(user: MongoRef, response: String? = nil) {
        self.user = user
        self.response = response
    }
}

extension GoMember: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(user)
    }
    
    static func == (lhs: GoMember, rhs: GoMember) -> Bool {
        lhs.user == rhs.user
    }
    
}
