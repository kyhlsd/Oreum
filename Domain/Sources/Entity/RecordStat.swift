//
//  RecordStat.swift
//  Domain
//
//  Created by 김영훈 on 10/31/25.
//

import Foundation

public struct RecordStat {
    public let mountainCount: Int
    public let climbCount: Int
    public let totalHeight: Int

    public init(mountainCount: Int, climbCount: Int, totalHeight: Int) {
        self.mountainCount = mountainCount
        self.climbCount = climbCount
        self.totalHeight = totalHeight
    }
}
