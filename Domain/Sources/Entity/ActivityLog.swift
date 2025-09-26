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
}

extension ActivityLog {
    public static var dummy: [ActivityLog] {
        // 랜덤 시작 시간 생성 (연도, 월, 일, 시, 분, 초 랜덤)
        let year = Int.random(in: 2023...2025)
        let month = Int.random(in: 1...12)
        let day = Int.random(in: 1...28)
        let hour = Int.random(in: 0...23)
        let minute = Int.random(in: 0...59)
        let second = Int.random(in: 0...59)
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        
        let calendar = Calendar.current
        let startDate = calendar.date(from: components) ?? Date()
        
        // 5분 간격으로 40개의 로그 생성
        return (0..<40).map { i in
            let logDate = startDate.addingTimeInterval(TimeInterval(i * 5 * 60))
            
            let randomStep = Int.random(in: 500...5000)
            let randomDistance = Int.random(in: 400...4000)
            
            return ActivityLog(
                id: UUID().uuidString,
                time: logDate,
                step: randomStep,
                distance: randomDistance
            )
        }
    }
}
