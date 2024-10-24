//
//  Preferences.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 24/10/24.
//

import Vapor

enum Gender: String, Content {
    case male
    case female
    case no_binary
}

enum AgeRange: String, Content {
    case childhood
    case puberty
    case teenager
    case young_adult
    case elder
}

enum TravelStatus: String, Content {
    case finished
    case canceled
    case waiting_travelers
    case going_to_destination
    case with_incidents
}

enum TransportServices: String, Content {
    case walk
    case uber
    case taxi
    case public_transport
}
