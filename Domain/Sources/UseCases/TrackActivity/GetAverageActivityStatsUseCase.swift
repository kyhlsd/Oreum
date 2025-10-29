//
//  GetAverageActivityStatsUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/28/25.
//

import Foundation
import Combine

public protocol GetAverageActivityStatsUseCase {
    func execute() -> AnyPublisher<Result<AverageActivityStat, Error>, Never>
}

public final class GetAverageActivityStatsUseCaseImpl: GetAverageActivityStatsUseCase {
    private let repository: ClimbRecordRepository

    public init(repository: ClimbRecordRepository) {
        self.repository = repository
    }

    public func execute() -> AnyPublisher<Result<AverageActivityStat, Error>, Never> {
        return repository.fetch(keyword: "", isOnlyBookmarked: false)
            .map { result in
                switch result {
                case .success(let records):
                    let stats = self.calculateAverageStats(from: records)
                    return .success(stats)
                case .failure(let error):
                    return .failure(error)
                }
            }
            .eraseToAnyPublisher()
    }

    private func calculateAverageStats(from records: [ClimbRecord]) -> AverageActivityStat {
        // ActivityLog가 있는 레코드만 필터링
        let validRecords = records.filter { !$0.timeLog.isEmpty }

        guard !validRecords.isEmpty else {
            return .empty
        }

        var totalMinutes = 0
        var totalExerciseMinutes = 0
        var totalRestMinutes = 0
        var totalDistance = 0

        for record in validRecords {
            let logs = record.timeLog.sorted { $0.time < $1.time }

            guard let startTime = logs.first?.time,
                  let endTime = logs.last?.time else {
                continue
            }

            // 총 소요시간 (분)
            let minutes = Int(endTime.timeIntervalSince(startTime) / 60)
            totalMinutes += minutes

            // 운동 시간과 휴식 시간 계산
            var exerciseMinutes = 0
            var restMinutes = 0

            for i in 0..<logs.count - 1 {
                let currentLog = logs[i]
                let nextLog = logs[i + 1]

                let intervalMinutes = Int(nextLog.time.timeIntervalSince(currentLog.time) / 60)

                // 걸음 수가 적으면 휴식, 많으면 운동으로 간주
                // 5분당 100걸음 미만이면 휴식으로 판단
                let threshold = 100
                if nextLog.step < threshold {
                    restMinutes += intervalMinutes
                } else {
                    exerciseMinutes += intervalMinutes
                }
            }

            totalExerciseMinutes += exerciseMinutes
            totalRestMinutes += restMinutes

            // 총 이동거리
            let distance = logs.reduce(0) { $0 + $1.distance }
            totalDistance += distance
        }

        let count = validRecords.count

        let avgTotalMinutes = totalMinutes / count
        let avgExerciseMinutes = totalExerciseMinutes / count
        let avgRestMinutes = totalRestMinutes / count

        // 평균 속도 (m/m)
        let avgSpeed = totalMinutes > 0 ? Double(totalDistance) / Double(totalMinutes) : 0.0

        return AverageActivityStat(
            averageTotalMinutes: avgTotalMinutes,
            averageExerciseMinutes: avgExerciseMinutes,
            averageRestMinutes: avgRestMinutes,
            averageSpeed: avgSpeed
        )
    }
}
