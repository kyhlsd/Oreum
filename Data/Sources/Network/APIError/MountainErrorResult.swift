//
//  MountainErrorResult.swift
//  Data
//
//  Created by 김영훈 on 10/25/25.
//

import Foundation

struct MountainErrorResult: APIErrorConvertible {
    private let errorMessage: String
    
    var message: String {
        return errorMessage
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.errorMessage = try container.decode(String.self)
    }
}
