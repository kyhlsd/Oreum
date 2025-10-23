//
//  ForecastItem.swift
//  Domain
//
//  Created by 김영훈 on 10/23/25.
//

import Foundation

// 기상청 단기예보 API의 개별 예보 항목
public struct ForecastItem {
    public let date: String          // 예보 날짜 (yyyyMMdd)
    public let time: String          // 예보 시각 (HHmm)
    public let category: String      // 예보 카테고리 (TMP, POP, PTY 등)
    public let value: String         // 예보 값

    public init(date: String, time: String, category: String, value: String) {
        self.date = date
        self.time = time
        self.category = category
        self.value = value
    }
}
