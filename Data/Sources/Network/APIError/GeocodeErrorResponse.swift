//
//  GeocoderErrorResponse.swift
//  Data
//
//  Created by 김영훈 on 10/6/25.
//

import Foundation

struct GeocodeErrorResponse: APIErrorConvertible {
    let error: GeocodeError
    var message: String {
        return error.text
    }
}

struct GeocodeError: Decodable {
    let level: Int
    let code: String
    let text: String
}
