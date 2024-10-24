//
//  Incidents.swift
//  GoMigoModel
//
//  Created by ADMIN UNACH on 17/10/24.
//

import Vapor

final class Incidents: Content {
    var happened_while: GoTravel
    var happened_on: Date
    var detected_by: Detecters
    var confirmed_by: Detecters
    var severity: Severity
    
    enum Detecters: Content {
        case siri
        case gomigo_ia
        case user
        case alert_contact
        case none
    }
    
    enum Severity: Content {
        case good
        case on_alert
        case something_bad_hapenned
    }
}
