//
//  ActivityLog.swift
//  Domain
//
//  Created by 김영훈 on 9/26/25.
//

import Foundation

public struct ActivityLog: Hashable {
    public let id: String
    public let time: Date
    public let step: Int
    public let distance: Int
    
    public init(id: String, time: Date, step: Int, distance: Int) {
        self.id = id
        self.time = time
        self.step = step
        self.distance = distance
    }
}

extension ActivityLog {
    public static var dummy: [ActivityLog] {
        // 랜덤 시작 시간 생성 (오전 8~10시 사이)
        let year = Int.random(in: 2024...2025)
        let month = Int.random(in: 1...12)
        let day = Int.random(in: 1...28)
        let hour = Int.random(in: 8...10)
        let minute = Int.random(in: 0...59)

        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = 0

        let calendar = Calendar.current
        let startDate = calendar.date(from: components) ?? Date()

        var result: [ActivityLog] = []

        // 초기 로그 (0/0)
        result.append(ActivityLog(
            id: UUID().uuidString,
            time: startDate,
            step: 0,
            distance: 0
        ))

        // 등산 시뮬레이션 (약 2-3시간)
        let totalIntervals = Int.random(in: 24...36) // 2~3시간
        var isResting = false
        var restCount = 0

        for i in 1...totalIntervals {
            let logDate = startDate.addingTimeInterval(TimeInterval(i * 5 * 60)) // 5분 간격

            // 10-15분마다 5분 휴식
            if i % Int.random(in: 2...3) == 0 && !isResting {
                isResting = true
                restCount = 0
            }

            let step: Int
            let distance: Int

            if isResting {
                // 휴식 중 (거의 움직이지 않음)
                step = Int.random(in: 0...20)
                distance = Int.random(in: 0...15)
                restCount += 1

                if restCount >= 1 { // 5분 휴식 후
                    isResting = false
                }
            } else {
                // 등산 중 (5분당 평균 300-500걸음, 200-350m)
                // 등산 초반/중반/후반에 따라 속도 조절
                let progress = Double(i) / Double(totalIntervals)

                if progress < 0.3 { // 초반: 빠른 속도
                    step = Int.random(in: 400...550)
                    distance = Int.random(in: 280...380)
                } else if progress < 0.7 { // 중반: 중간 속도
                    step = Int.random(in: 300...450)
                    distance = Int.random(in: 200...320)
                } else { // 후반: 느린 속도 (피로)
                    step = Int.random(in: 250...400)
                    distance = Int.random(in: 170...280)
                }
            }

            result.append(ActivityLog(
                id: UUID().uuidString,
                time: logDate,
                step: step,
                distance: distance
            ))
        }

        return result
    }
}
