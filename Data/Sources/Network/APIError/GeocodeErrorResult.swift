//
//  GeocodeErrorResult.swift
//  Data
//
//  Created by 김영훈 on 10/6/25.
//

import Foundation

struct GeocodeErrorResult: APIErrorConvertible {
    
    private let error: GeocodeError
    
    private struct GeocodeError: Decodable {
        let level: Int
        let code: String
        let text: String
    }
    
    var message: String {
        return error.text
    }
}
