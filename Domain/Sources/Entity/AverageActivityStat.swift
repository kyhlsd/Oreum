//
//  ActivityStats.swift
//  Domain
//
//  Created by 김영훈 on 10/28/25.
//

import Foundation

public struct AverageActivityStat {
    public let averageTotalMinutes: Int      // 평균 총 소요시간 (분)
    public let averageExerciseMinutes: Int   // 평균 운동 시간 (분)
    public let averageRestMinutes: Int       // 평균 휴식 시간 (분)
    public let averageSpeed: Double          // 평균 속도 (m/분)

    public init(
        averageTotalMinutes: Int,
        averageExerciseMinutes: Int,
        averageRestMinutes: Int,
        averageSpeed: Double
    ) {
        self.averageTotalMinutes = averageTotalMinutes
        self.averageExerciseMinutes = averageExerciseMinutes
        self.averageRestMinutes = averageRestMinutes
        self.averageSpeed = averageSpeed
    }
}

extension AverageActivityStat {
    public static var empty: AverageActivityStat {
        return AverageActivityStat(
            averageTotalMinutes: 0,
            averageExerciseMinutes: 0,
            averageRestMinutes: 0,
            averageSpeed: 0
        )
    }
}
