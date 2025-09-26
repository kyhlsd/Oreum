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
        (0..<3).map { _ in
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
            let randomDate = calendar.date(from: components) ?? Date()
            
            let randomStep = Int.random(in: 500...5000)
            let randomDistance = Int.random(in: 400...4000)
            
            return ActivityLog(
                id: UUID().uuidString,
                time: randomDate,
                step: randomStep,
                distance: randomDistance
            )
        }
    }
}
