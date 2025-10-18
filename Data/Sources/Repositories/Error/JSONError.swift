//
//  JSONError.swift
//  Data
//
//  Created by 김영훈 on 10/17/25.
//

import Foundation

public enum JSONError: Error {

    // JSON 파일을 찾을 수 없는 경우
    case fileNotFound

    // JSON 파일을 읽을 수 없는 경우
    case fileReadFailed

    // JSON 디코딩에 실패한 경우
    case decodingFailed

    // 산 정보를 찾을 수 없는 경우
    case mountainNotFound

    // 데이터가 비어있는 경우
    case emptyData

    // 알 수 없는 오류
    case unknown
}

extension JSONError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "JSON 파일을 찾을 수 없습니다."

        case .fileReadFailed:
            return "JSON 파일을 읽는 중 오류가 발생했습니다."

        case .decodingFailed:
            return "JSON 데이터를 처리하는 중 오류가 발생했습니다."

        case .mountainNotFound:
            return "산 정보를 찾을 수 없습니다."

        case .emptyData:
            return "데이터가 비어있습니다."

        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }

}
