//
//  DailyForecast.swift
//  Domain
//
//  Created by 김영훈 on 10/7/25.
//

import Foundation

public struct DailyForecast {
    public let date: Date
    public let minTemp: Double
    public let maxTemp: Double
    public let pop: Int // 강수 확률 (%)
    public let pty: Int // 강수 형태 (0: 없음, 1: 비, 2: 비/눈, 3: 눈, 4: 눈/비)
    
    public init(date: Date, minTemp: Double, maxTemp: Double, pop: Int, pty: Int) {
        self.date = date
        self.minTemp = minTemp
        self.maxTemp = maxTemp
        self.pop = pop
        self.pty = pty
    }
}
