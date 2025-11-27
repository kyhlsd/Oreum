//
//  ActivityStatUseCase.swift
//  Domain
//
//  Created by 김영훈 on 9/30/25.
//

import Foundation

public protocol ActivityStatUseCase {
    func execute(activityLogs: [ActivityLog]) -> ActivityStat
}

public final class ActivityStatUseCaseImpl: ActivityStatUseCase {
    
    public init() {}
    
    public func execute(activityLogs: [ActivityLog]) -> ActivityStat {
        guard let first = activityLogs.first, let last = activityLogs.last else {
            return ActivityStat(
                totalTimeMinutes: 0,
                totalDistance: 0,
                totalSteps: 0,
                startTime: nil,
                endTime: nil,
                exerciseMinutes: 0,
                restMinutes: 0
            )
        }
        
        let totalSteps = activityLogs.reduce(0) { $0 + $1.step }
        let totalDistance = activityLogs.reduce(0) { $0 + $1.distance }
        let totalTimeMinutes = Int(last.time.timeIntervalSince(first.time) / 60)

        // 초기값을 제외한 로그들 사용 (마지막 로그 포함)
        let logsToProcess = activityLogs.count > 1 ? Array(activityLogs[1...]) : []

        var exerciseMinutes = 0

        for (index, log) in logsToProcess.enumerated() {
            let isLastLog = (index == logsToProcess.count - 1)

            if isLastLog {
                // 마지막 로그: 실제 시간을 계산하고 분당 20보 기준으로 판단
                let timeInterval = log.time.timeIntervalSince(activityLogs[activityLogs.count - 2].time)
                let minutes = Int(timeInterval / 60)
                let stepsPerMinute = minutes > 0 ? Double(log.step) / Double(minutes) : 0

                if stepsPerMinute >= 20 {
                    exerciseMinutes += minutes
                }
            } else {
                // 중간 로그들: 5분 간격, 100보 기준
                if log.step >= 100 {
                    exerciseMinutes += 5
                }
            }
        }

        let restMinutes = totalTimeMinutes - exerciseMinutes

        return ActivityStat(
            totalTimeMinutes: totalTimeMinutes,
            totalDistance: totalDistance,
            totalSteps: totalSteps,
            startTime: first.time,
            endTime: last.time,
            exerciseMinutes: exerciseMinutes,
            restMinutes: restMinutes
        )
    }
}

