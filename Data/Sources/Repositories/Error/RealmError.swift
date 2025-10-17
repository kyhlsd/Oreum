//
//  RealmError.swift
//  Data
//
//  Created by 김영훈 on 10/17/25.
//

import Foundation

public enum RealmError {

    // Repository 인스턴스가 해제된 경우
    case repositoryDeallocated

    // 레코드를 찾을 수 없는 경우
    case recordNotFound

    // 이미지를 찾을 수 없는 경우
    case imageNotFound

    // ObjectId 변환에 실패한 경우
    case invalidObjectID

    // Realm 초기화에 실패한 경우
    case realmInitializationFailed

    // Realm Write 트랜잭션 실패
    case writeTransactionFailed

    // Realm Read 작업 실패
    case readOperationFailed

    // 알 수 없는 오류
    case unknown
}

extension RealmError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .repositoryDeallocated:
            return "Repository가 이미 해제되었습니다."

        case .recordNotFound:
            return "레코드를 찾을 수 없습니다."

        case .imageNotFound:
            return "이미지를 찾을 수 없습니다."

        case .invalidObjectID:
            return "유효하지 않은 ObjectID입니다."

        case .realmInitializationFailed:
            return "Realm 데이터베이스를 초기화할 수 없습니다."

        case .writeTransactionFailed:
            return "데이터베이스 쓰기 작업에 실패했습니다."

        case .readOperationFailed:
            return "데이터베이스 읽기 작업에 실패했습니다."

        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
}
