//
//  ActivityStat.swift
//  Domain
//
//  Created by 김영훈 on 9/30/25.
//

import Foundation

public struct ActivityStat {
    public let totalTimeMinutes: Int
    public let totalDistance: Int
    public let totalSteps: Int
    public let startTime: Date?
    public let endTime: Date?
    public let exerciseMinutes: Int
    public let restMinutes: Int
}
