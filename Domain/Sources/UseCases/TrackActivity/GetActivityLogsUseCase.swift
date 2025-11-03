//
//  GetActivityLogsUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/1/25.
//

import Foundation
import Combine
import simd

public protocol GetActivityLogsUseCase {
    func execute() -> AnyPublisher<Result<[ActivityLog], Error>, Never>
}

public final class GetActivityLogsUseCaseImpl: GetActivityLogsUseCase {
    private let repository: TrackActivityRepository
    
    private let correctionService = ActivityDataCorrectionService()
    private let smoothingService = ActivityKalmanSmoothingService()
    
    public init(repository: TrackActivityRepository) {
        self.repository = repository
    }
    
    public func execute() -> AnyPublisher<Result<[ActivityLog], Error>, Never> {
        return repository.getActivityLogs()
            .map { [weak self] result in
                guard let self else {
                    return .failure(NSError(domain: "GetActivityLogsUseCaseImpl", code: -1, userInfo: [NSLocalizedDescriptionKey: "UseCase가 이미 해제되었습니다."]))
                }
                switch result {
                case .success(let logs):
                    // 휴리스틱 보정
                    let corrected = self.correctionService.correct(logs)
                    // 칼만 필터
                    let smoothed = self.smoothingService.smooth(corrected)
                    return .success(smoothed)
                case .failure(let error):
                    return .failure(error)
                }
            }
            .eraseToAnyPublisher()
    }
}

private final class ActivityDataCorrectionService {
    func correct(_ logs: [ActivityLog]) -> [ActivityLog] {
        guard logs.count >= 2 else { return logs }
        var corrected = logs
        
        for i in 1..<logs.count {
            let prev = corrected[i - 1]
            let current = corrected[i]
            let diffStep = current.step - prev.step
            let diffDist = current.distance - prev.distance
            
            if diffStep > 200 {
                let adjustmentStep = diffStep / 2
                let adjustmentDist = diffDist / 2
                
                corrected[i - 1] = ActivityLog(
                    id: prev.id,
                    time: prev.time,
                    step: prev.step + adjustmentStep,
                    distance: prev.distance + adjustmentDist
                )
                
                corrected[i] = ActivityLog(
                    id: current.id,
                    time: current.time,
                    step: current.step - adjustmentStep,
                    distance: current.distance - adjustmentDist
                )
            }
        }
        return corrected
    }
}

private final class ActivityKalmanSmoothingService {
    func smooth(_ logs: [ActivityLog]) -> [ActivityLog] {
        guard !logs.isEmpty else { return [] }
        
        var smoothed: [ActivityLog] = []
        
        // 유효한 초기값 찾기 (0이 아닌 첫 데이터)
        guard let firstValid = logs.first(where: { $0.step > 0 || $0.distance > 0 }) else {
            // 모두 0이면 그대로 반환
            return logs
        }
        
        var stepEstimate = Double(firstValid.step)
        var distanceEstimate = Double(firstValid.distance)
        var stepError = 1.0
        var distanceError = 1.0
        
        let q = 0.01   // process noise
        let r = 0.5    // measurement noise
        
        for log in logs {
            // 0 데이터는 그대로 통과
            if log.step == 0 && log.distance == 0 {
                smoothed.append(log)
                continue
            }
            
            // Prediction
            stepError += q
            distanceError += q
            
            // Measurement update
            let kStep = stepError / (stepError + r)
            let kDist = distanceError / (distanceError + r)
            
            stepEstimate = stepEstimate + kStep * (Double(log.step) - stepEstimate)
            distanceEstimate = distanceEstimate + kDist * (Double(log.distance) - distanceEstimate)
            
            stepError = (1 - kStep) * stepError
            distanceError = (1 - kDist) * distanceError
            
            smoothed.append(ActivityLog(
                id: log.id,
                time: log.time,
                step: Int(stepEstimate),
                distance: Int(distanceEstimate)
            ))
        }
        
        return smoothed
    }
}


