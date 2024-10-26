//
//  GoPreferences.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 24/10/24.
//

import Vapor
import Fluent

final class GoPreferences: Fields, @unchecked Sendable {
    
    @Field(key: "matching_gender")
    var matchingGender: Set<Gender>
    
    @Field(key: "age_range")
    var ageRange: Set<AgeRange>
    
    @Field(key: "match_foreigns")
    var matchForeigns: Bool
    
    init() { }
    
    init(matchingGender: Set<Gender>, ageRange: Set<AgeRange>, matchForeignes: Bool) {
        self.matchingGender = matchingGender
        self.ageRange = ageRange
        self.matchForeigns = matchForeignes
    }
    
    static let common = GoPreferences(
        matchingGender: [.female, .male, .no_binary],
        ageRange: [.childhood, .elder],
        matchForeignes: true)
}

extension GoPreferences {

    func intersection(with groupB: GoPreferences) -> GoPreferences {
        var matchingGender = self.matchingGender
            .intersection(groupB.matchingGender)
        var ageRange = self.ageRange
            .intersection(groupB.ageRange)
        var matchForeigns = self.matchForeigns && groupB.matchForeigns
        
        return GoPreferences(
            matchingGender: matchingGender,
            ageRange: ageRange,
            matchForeignes: matchForeigns)
    }
}
