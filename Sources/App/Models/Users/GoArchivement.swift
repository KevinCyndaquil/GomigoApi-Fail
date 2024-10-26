//
//  GoArchivement.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 24/10/24.
//

import Vapor
import Fluent

final class GoArchivement: Model, @unchecked Sendable {
    static let schema = "archivements"
    
    @Field(key: .id)
    var id: UUID?
    
    @Field(key: "icon")
    var icon: Data?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "description")
    var description: String
    
    @Field(key: "progress_needed")
    var progressNeeded: Float
    
    init() { }
    
    init(id: UUID? = nil, icon: Data? = nil, name: String, description: String, progressNeeded: Float) {
        self.id = id
        self.icon = icon
        self.name = name
        self.description = description
        self.progressNeeded = progressNeeded
    }
}
