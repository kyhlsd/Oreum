//
//  MountainErrorResult.swift
//  Data
//
//  Created by 김영훈 on 10/23/25.
//

import Foundation

struct MountainErrorResult: APIErrorConvertible {
    
    private let result: MountainError
    
    var message: String {
        return result.message
    }
    
}

extension MountainErrorResult {
    
    enum CodingKeys: String, CodingKey {
        case result = "RESULT"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.result = try container.decode(MountainErrorResult.MountainError.self, forKey: .result)
    }
    
    private struct MountainError: Decodable {
        let code: String
        let message: String
        
        enum CodingKeys: String, CodingKey {
            case code = "CODE"
            case message = "MESSAGE"
        }
        
        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<MountainErrorResult.MountainError.CodingKeys> = try decoder.container(keyedBy: MountainErrorResult.MountainError.CodingKeys.self)
            self.code = try container.decode(String.self, forKey: MountainErrorResult.MountainError.CodingKeys.code)
            self.message = try container.decode(String.self, forKey: MountainErrorResult.MountainError.CodingKeys.message)
        }
    }
    
}
