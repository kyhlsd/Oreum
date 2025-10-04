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
    public var images: [String]
    public var score: Int
    public var comment: String
    public var isBookmarked: Bool
    public let climbDate: Date

    public init(id: String, mountain: Mountain, timeLog: [ActivityLog], images: [String], score: Int, comment: String, isBookmarked: Bool, climbDate: Date) {
        self.id = id
        self.mountain = mountain
        self.timeLog = timeLog
        self.images = images
        self.score = score
        self.comment = comment
        self.isBookmarked = isBookmarked
        self.climbDate = climbDate
    }
}

extension ClimbRecord {
    public static let dummy = [
        ClimbRecord(
            id: UUID().uuidString,
            mountain: Mountain.dummy[0],
            timeLog: ActivityLog.dummy,
            images: ["hallasan1.jpg", "hallasan2.jpg"],
            score: 5,
            comment: "comment",
            isBookmarked: true,
            climbDate: Date().addingTimeInterval(-Double.random(in: 0...86400*30))
        ),
        ClimbRecord(
            id: UUID().uuidString,
            mountain:  Mountain.dummy[1],
            timeLog: ActivityLog.dummy,
            images: ["seoraksan1.jpg"],
            score: 4,
            comment: "comment",
            isBookmarked: false,
            climbDate: Date().addingTimeInterval(-Double.random(in: 0...86400*30))
        ),
        ClimbRecord(
            id: UUID().uuidString,
            mountain:  Mountain.dummy[0],
            timeLog: ActivityLog.dummy,
            images: ["hallasan1.jpg", "hallasan2.jpg"],
            score: 5,
            comment: "comment",
            isBookmarked: true,
            climbDate: Date().addingTimeInterval(-Double.random(in: 0...86400*30))
        ),
        ClimbRecord(
            id: UUID().uuidString,
            mountain:  Mountain.dummy[2],
            timeLog: ActivityLog.dummy,
            images: [],
            score: 3,
            comment: "comment",
            isBookmarked: true,
            climbDate: Date().addingTimeInterval(-Double.random(in: 0...86400*30))
        ),
        ClimbRecord(
            id: UUID().uuidString,
            mountain:  Mountain.dummy[1],
            timeLog: ActivityLog.dummy,
            images: ["seoraksan1.jpg"],
            score: 4,
            comment: "comment",
            isBookmarked: false,
            climbDate: Date().addingTimeInterval(-Double.random(in: 0...86400*30))
        ),
        ClimbRecord(
            id: UUID().uuidString,
            mountain:  Mountain.dummy[3],
            timeLog: ActivityLog.dummy,
            images: ["jirisann1.jpg"],
            score: 4,
            comment: "comment",
            isBookmarked: false,
            climbDate: Date().addingTimeInterval(-Double.random(in: 0...86400*30))
        ),
        ClimbRecord(
            id: UUID().uuidString,
            mountain:  Mountain.dummy[4],
            timeLog: ActivityLog.dummy,
            images: [],
            score: 3,
            comment: "comment",
            isBookmarked: true,
            climbDate: Date().addingTimeInterval(-Double.random(in: 0...86400*30))
        ),

    ]
}
