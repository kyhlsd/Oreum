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
    public let mountainName: String
    public let mountainAddress: String
    public let height: Int
    public let timeLog: [ActivityLog]
    public let images: [String]
    public let score: Int
    public let isBookmarked: Bool
}

extension ClimbRecord {
    public static let dummy: [ClimbRecord] = [
        ClimbRecord(
            id: UUID().uuidString,
            mountainId: "MT001",
            mountainName: "한라산",
            mountainAddress: "제주특별자치도 제주시",
            height: 1950,
            timeLog: ActivityLog.dummy,
            images: ["hallasan1.jpg", "hallasan2.jpg"],
            score: 5,
            isBookmarked: true
        ),
        ClimbRecord(
            id: UUID().uuidString,
            mountainId: "MT002",
            mountainName: "설악산",
            mountainAddress: "강원특별자치도 속초시",
            height: 1708,
            timeLog: ActivityLog.dummy,
            images: ["seoraksan1.jpg"],
            score: 4,
            isBookmarked: false
        ),
        ClimbRecord(
            id: UUID().uuidString,
            mountainId: "MT003",
            mountainName: "북한산",
            mountainAddress: "서울특별시 은평구",
            height: 836,
            timeLog: ActivityLog.dummy,
            images: [],
            score: 3,
            isBookmarked: true
        ),
        ClimbRecord(
            id: UUID().uuidString,
            mountainId: "MT004",
            mountainName: "지리산",
            mountainAddress: "전라남도 구례군",
            height: 1915,
            timeLog: ActivityLog.dummy,
            images: ["jirisann1.jpg"],
            score: 4,
            isBookmarked: false
        ),
        ClimbRecord(
            id: UUID().uuidString,
            mountainId: "MT005",
            mountainName: "태백산",
            mountainAddress: "강원도 태백시",
            height: 1567,
            timeLog: ActivityLog.dummy,
            images: [],
            score: 3,
            isBookmarked: true
        ),
        ClimbRecord(
            id: UUID().uuidString,
            mountainId: "MT006",
            mountainName: "오대산",
            mountainAddress: "강원도 평창군",
            height: 1563,
            timeLog: ActivityLog.dummy,
            images: ["odaesan1.jpg"],
            score: 4,
            isBookmarked: false
        ),
        ClimbRecord(
            id: UUID().uuidString,
            mountainId: "MT007",
            mountainName: "덕유산",
            mountainAddress: "전라북도 무주군",
            height: 1614,
            timeLog: ActivityLog.dummy,
            images: [],
            score: 5,
            isBookmarked: true
        ),
        ClimbRecord(
            id: UUID().uuidString,
            mountainId: "MT008",
            mountainName: "계룡산",
            mountainAddress: "충청남도 계룡시",
            height: 845,
            timeLog: ActivityLog.dummy,
            images: ["gyeryongsan1.jpg"],
            score: 3,
            isBookmarked: false
        ),
        ClimbRecord(
            id: UUID().uuidString,
            mountainId: "MT009",
            mountainName: "소백산",
            mountainAddress: "충청북도 단양군",
            height: 1449,
            timeLog: ActivityLog.dummy,
            images: [],
            score: 4,
            isBookmarked: true
        ),
        ClimbRecord(
            id: UUID().uuidString,
            mountainId: "MT010",
            mountainName: "속리산",
            mountainAddress: "충청북도 보은군",
            height: 1058,
            timeLog: ActivityLog.dummy,
            images: ["sokrisan1.jpg", "sokrisan2.jpg"],
            score: 3,
            isBookmarked: false
        )
    ]
}
