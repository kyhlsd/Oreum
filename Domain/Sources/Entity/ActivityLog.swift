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
        
        var result: [ActivityLog] = []
        
        result.append(ActivityLog(
            id: UUID().uuidString,
            time: startDate,
            step: 0,
            distance: 0
        ))
        
        for i in 1..<40 {
            let logDate = startDate.addingTimeInterval(TimeInterval(i * 5 * 60))
            let step = Int.random(in: 0...1000)
            let distance = Int.random(in: 0...500)
            
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
