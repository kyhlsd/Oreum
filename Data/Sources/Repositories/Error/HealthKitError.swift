//
//  HealthKitError.swift
//  Data
//
//  Created by 김영훈 on 10/17/25.
//

import Foundation

public enum HealthKitError: Error {
    
    // Repository 인스턴스가 해제된 경우
    case repositoryDeallocated
    
    // HealthKit이 사용 불가능한 경우
    case healthKitNotAvailable
    
    // 권한 요청에 실패한 경우
    case authorizationFailed
    
    // 측정 중이 아닌 경우
    case noTrackingSession
    
    // 권한이 거부되어 있는 경우
    case dataAccessDenied
    
    // 데이터 가져오기에 실패한 경우
    case queryExecutionFailed
    
    // 알 수 없는 오류
    case unknown
}

extension HealthKitError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .repositoryDeallocated:
            return "HealthKit Repository가 해제되었습니다."
            
        case .healthKitNotAvailable:
            return "이 기기에서는 HealthKit을 사용할 수 없습니다."
            
        case .authorizationFailed:
            return "HealthKit 권한 요청에 실패했습니다."
            
        case .noTrackingSession:
            return "진행 중인 측정 세션이 없습니다."
            
        case .dataAccessDenied:
            return "건강 데이터에 접근할 수 없습니다. 설정에서 권한을 확인해주세요."
            
        case .queryExecutionFailed:
            return "건강 데이터를 불러오는 중 오류가 발생했습니다."
            
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        }
    }
    
}
