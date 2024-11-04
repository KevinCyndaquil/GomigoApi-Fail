//
//  Preferences.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 24/10/24.
//

import Vapor

enum Sex: String, Content {
    case male
    case female
}

enum Gender: String, Content {
    case male
    case female
    case no_binary
}

enum AgeRange: Int, Content {
    case childhood = 5
    case puberty = 12
    case teenager = 16
    case young_adult = 20
    case adult = 30
    case elder = 55
    
    static func range(birthday: Date) -> AgeRange? {
        let calendar = Calendar.current
        let currentDate = Date()
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: currentDate)
        //hola
        switch ageComponents.year ?? 0 {
        case ..<AgeRange.childhood.rawValue:
            return nil
        case AgeRange.childhood.rawValue..<AgeRange.puberty.rawValue:
            return .childhood
        case AgeRange.puberty.rawValue..<AgeRange.teenager.rawValue:
            return .puberty
        case AgeRange.teenager.rawValue..<AgeRange.young_adult.rawValue:
            return .teenager
        case AgeRange.young_adult.rawValue..<AgeRange.adult.rawValue:
            return .young_adult
        case AgeRange.adult.rawValue..<AgeRange.elder.rawValue:
            return .adult
        default:
            return .elder
        }
    }
}

enum TransportServices: String, Content {
    case taxi
    case uber
    case didi
    case public_transport
    case mototaxi
    case walking
    case particular
}
