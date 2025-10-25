//
//  APIError.swift
//  Data
//
//  Created by 김영훈 on 10/6/25.
//

import Foundation

enum APIError: LocalizedError {
    case network
    case some(message: String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .network:
            return "네트워크 연결이 일시적으로 원활하지 않습니다.\n데이터 또는 Wi-Fi 연결 상태를 확인해주세요."
        case .some(let message):
            return message
        case .unknown:
            return "알 수 없는 에러가 발생했습니다."
        }
    }
}

public protocol APIErrorConvertible: Decodable {
    var message: String { get }
}
