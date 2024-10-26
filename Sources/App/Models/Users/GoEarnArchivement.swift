//
//  GoEarnArchivement.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 26/10/24.
//

import Vapor
import Fluent

final class GoEarnArchivement: Fields, @unchecked Sendable, Content {
    
    @Field(key: "archivement")
    var archivement: MongoRef
    
    @Field(key: "obtained")
    var obtained: Date
    
    @Field(key: "progress")
    var progress: Float
    
}

extension GoEarnArchivement: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(archivement)
    }
    
    static func == (lhs: GoEarnArchivement, rhs: GoEarnArchivement) -> Bool {
        lhs.archivement == rhs.archivement
    }
}
