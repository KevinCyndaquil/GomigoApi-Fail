//
//  GoRequest.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 24/10/24.
//

import Vapor
import Fluent

final class GoRequest: Fields, @unchecked Sendable, Content {
    
    @Field(key: "match_request")
    var matchRequest: GoMatch
    
    @Field(key: "from")
    var from: GoUser
    
    @Field(key: "to")
    var to: GoUser
    
    @Field(key: "current_ubication")
    var currentUbication: Place?
    
    @Field(key: "reason")
    var reason: GoReason
}
