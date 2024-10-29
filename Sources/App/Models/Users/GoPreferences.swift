//
//  GoPreferences.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 24/10/24.
//

import Vapor
import Fluent

final class GoPreferences: Fields, @unchecked Sendable {
    
    @Field(key: "matchin_sex")
    var matchingSex: Set<Sex>
    
    @Field(key: "matching_gender")
    var matchingGender: Set<Gender>
    
    @Field(key: "age_range")
    var ageRange: Set<AgeRange>
    
    @Field(key: "match_foreigns")
    var matchForeigns: Bool
    
    init() { }
    
    
    init(matchingSex: Set<Sex>, matchingGender: Set<Gender>, ageRange: Set<AgeRange>, matchForeigns: Bool) {
        self.matchingSex = matchingSex
        self.matchingGender = matchingGender
        self.ageRange = ageRange
        self.matchForeigns = matchForeigns
    }
    
    static let common = GoPreferences(
        matchingSex: [.male, .female],
        matchingGender: [.female, .male, .no_binary],
        ageRange: [.childhood, .elder],
        matchForeigns: true)
}

extension GoPreferences {

    func intersection(with rhs: GoPreferences) -> GoPreferences {
        let matchingSex = self.matchingSex
            .intersection(rhs.matchingSex)
        let matchingGender = self.matchingGender
            .intersection(rhs.matchingGender)
        let ageRange = self.ageRange
            .intersection(rhs.ageRange)
        let matchForeigns = self.matchForeigns && rhs.matchForeigns
        
        return GoPreferences(
            matchingSex: matchingSex,
            matchingGender: matchingGender,
            ageRange: ageRange,
            matchForeigns: matchForeigns)
    }
}
