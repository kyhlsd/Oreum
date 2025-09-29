//
//  ClimbRecord.swift
//  Domain
//
//  Created by 김영훈 on 9/26/25.
//

import Foundation

public struct ClimbRecord: Hashable {
    public let id: String
    public let mountain: Mountain
    public let timeLog: [ActivityLog]
    public let images: [String]
    public var score: Int
    public var comment: String
    public var isBookmarked: Bool
    
    // TODO: ViewModel로 옮기기
    public var totalDuration: String {
        guard let first = timeLog.first?.time,
              let last = timeLog.last?.time else {
            return "기록 없음"
        }
        
        let interval = last.timeIntervalSince(first)
        let totalMinutes = Int(interval) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        if hours > 0 {
            return "\(hours)시간 \(minutes)분"
        } else {
            return "\(minutes)분"
        }
    }
    
    public var step: String {
        guard let last = timeLog.last?.step else {
            return "기록 없음"
        }
        
        return last.formatted()
    }
}

extension ClimbRecord {
    public static let dummy: [ClimbRecord] = [
        ClimbRecord(
            id: UUID().uuidString,
            mountain: Mountain.dummy[0],
            timeLog: ActivityLog.dummy,
            images: ["hallasan1.jpg", "hallasan2.jpg"],
            score: 5,
            comment: "comment",
            isBookmarked: true
        ),
        ClimbRecord(
            id: UUID().uuidString,
            mountain:  Mountain.dummy[1],
            timeLog: ActivityLog.dummy,
            images: ["seoraksan1.jpg"],
            score: 4,
            comment: "comment",
            isBookmarked: false
        ),
        ClimbRecord(
            id: UUID().uuidString,
            mountain:  Mountain.dummy[0],
            timeLog: ActivityLog.dummy,
            images: ["hallasan1.jpg", "hallasan2.jpg"],
            score: 5,
            comment: "comment",
            isBookmarked: true
        ),
        ClimbRecord(
            id: UUID().uuidString,
            mountain:  Mountain.dummy[2],
            timeLog: ActivityLog.dummy,
            images: [],
            score: 3,
            comment: "comment",
            isBookmarked: true
        ),
        ClimbRecord(
            id: UUID().uuidString,
            mountain:  Mountain.dummy[1],
            timeLog: ActivityLog.dummy,
            images: ["seoraksan1.jpg"],
            score: 4,
            comment: "comment",
            isBookmarked: false
        ),
        ClimbRecord(
            id: UUID().uuidString,
            mountain:  Mountain.dummy[3],
            timeLog: ActivityLog.dummy,
            images: ["jirisann1.jpg"],
            score: 4,
            comment: "comment",
            isBookmarked: false
        ),
        ClimbRecord(
            id: UUID().uuidString,
            mountain:  Mountain.dummy[4],
            timeLog: ActivityLog.dummy,
            images: [],
            score: 3,
            comment: "comment",
            isBookmarked: true
        ),
        
    ]
}
