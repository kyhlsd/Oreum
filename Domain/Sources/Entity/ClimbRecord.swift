//
//  ClimbRecord.swift
//  Domain
//
//  Created by 김영훈 on 9/26/25.
//

import Foundation

public struct ClimbRecord: Hashable {
    public let id: String
    public let mountainId: String
    public let timeLog: [ActivityLog]
    public let images: [String]
    public var score: Int
    public var comment: String
    public var isBookmarked: Bool
}

extension ClimbRecord {
    public static let dummy: [ClimbRecord] = [
        ClimbRecord(
            id: UUID().uuidString,
            mountainId: "MT001",
            timeLog: ActivityLog.dummy,
            images: ["hallasan1.jpg", "hallasan2.jpg"],
            score: 5,
            comment: "comment",
            isBookmarked: true
        ),
        ClimbRecord(
            id: UUID().uuidString,
            mountainId: "MT002",
            timeLog: ActivityLog.dummy,
            images: ["seoraksan1.jpg"],
            score: 4,
            comment: "comment",
            isBookmarked: false
        ),
        ClimbRecord(
            id: UUID().uuidString,
            mountainId: "MT001",
            timeLog: ActivityLog.dummy,
            images: ["hallasan1.jpg", "hallasan2.jpg"],
            score: 5,
            comment: "comment",
            isBookmarked: true
        ),
        ClimbRecord(
            id: UUID().uuidString,
            mountainId: "MT003",
            timeLog: ActivityLog.dummy,
            images: [],
            score: 3,
            comment: "comment",
            isBookmarked: true
        ),
        ClimbRecord(
            id: UUID().uuidString,
            mountainId: "MT002",
            timeLog: ActivityLog.dummy,
            images: ["seoraksan1.jpg"],
            score: 4,
            comment: "comment",
            isBookmarked: false
        ),
        ClimbRecord(
            id: UUID().uuidString,
            mountainId: "MT004",
            timeLog: ActivityLog.dummy,
            images: ["jirisann1.jpg"],
            score: 4,
            comment: "comment",
            isBookmarked: false
        ),
        ClimbRecord(
            id: UUID().uuidString,
            mountainId: "MT005",
            timeLog: ActivityLog.dummy,
            images: [],
            score: 3,
            comment: "comment",
            isBookmarked: true
        ),
        
    ]
}
