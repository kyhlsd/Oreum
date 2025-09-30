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
        
        let totalSteps = activityLogs.map { $0.step }.reduce(0, +)
        let totalDistance = activityLogs.map { $0.distance }.reduce(0, +)
        let totalTimeMinutes = Int(last.time.timeIntervalSince(first.time) / 60)
        
        var exerciseMinutes = 0
        var restMinutes = 0
        for log in activityLogs {
            if log.distance >= 100 {
                exerciseMinutes += 5
            } else {
                restMinutes += 5
            }
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

