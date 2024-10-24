//
//  UserService.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 21/10/24.
//

import Vapor
import Fluent

final class UserService {
    let db: any Database
    
    init(database: any Database) {
        self.db = database
    }
    
    func select(id: UUID) async throws -> GoUserDTO? {
        try await GoUser.query(on: db)
            .filter(\.$id == id)
            .first()?
            .toDTO()
    }
}
