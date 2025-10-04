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

        let totalSteps = last.step // 마지막 로그의 누적 걸음수
        let totalDistance = last.distance // 마지막 로그의 누적 이동거리
        let totalTimeMinutes = Int(last.time.timeIntervalSince(first.time) / 60)

        // 초기값과 종료값을 제외한 중간 로그들만 사용
        let middleLogs = activityLogs.count > 2 ? Array(activityLogs[1..<activityLogs.count-1]) : []

        var exerciseMinutes = 0
        var restMinutes = 0
        for log in middleLogs {
            if log.distance >= 100 {
                exerciseMinutes += 5
            } else {
                restMinutes += 5
            }
        }

        // 중간 로그가 없는 경우 전체 시간을 운동 시간으로 계산
        if middleLogs.isEmpty && totalTimeMinutes > 0 {
            exerciseMinutes = totalTimeMinutes
        }

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

