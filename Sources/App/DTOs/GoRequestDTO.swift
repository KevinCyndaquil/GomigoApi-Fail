//
//  GoRequestDTO.swift
//  GoMigoAPI
//
//  Created by ADMIN UNACH on 28/10/24.
//

import Vapor

struct GoRequestDTO: Content {
    var id: UUID
    //var user: GoUserDTO // no necesito el usuario
    var response: GoRequest.Responses
}

extension GoRequest {
    func toDTO() -> GoRequestDTO {
        return GoRequestDTO(
            id: self.id,
            response: self.response)
    }
}
