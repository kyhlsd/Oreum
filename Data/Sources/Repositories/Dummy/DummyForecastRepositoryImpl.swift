//
//  DummyForecastRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 10/8/25.
//

import Foundation
import Combine
import Domain

public final class DummyForecastRepositoryImpl: ForecastRepository {

    // Test properties
    var mockForecastItems: [ForecastItem] = []
    var shouldReturnError = false
    var useMockData = false
    var lastNx: Int?
    var lastNy: Int?

    init() {}

    public func fetchShortTermForecast(nx: Int, ny: Int) -> AnyPublisher<Result<[ForecastItem], Error>, Never> {
        lastNx = nx
        lastNy = ny

        if shouldReturnError {
            return Just(.failure(NSError(domain: "Test", code: -1, userInfo: nil)))
                .eraseToAnyPublisher()
        }

        // Use mockForecastItems if useMockData flag is set
        if useMockData {
            return Just(.success(mockForecastItems))
                .eraseToAnyPublisher()
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"

        var dummyItems: [ForecastItem] = []

        // 7일치 더미 데이터 생성
        for dayOffset in 0..<7 {
            let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date()) ?? Date()
            let dateString = dateFormatter.string(from: date)

            // 하루에 8개 시간대 (3시간 간격)
            for hour in stride(from: 0, to: 24, by: 3) {
                let timeString = String(format: "%02d00", hour)

                // TMP (기온)
                dummyItems.append(ForecastItem(
                    date: dateString,
                    time: timeString,
                    category: "TMP",
                    value: String(format: "%.1f", Double.random(in: 10...28))
                ))

                // POP (강수확률)
                dummyItems.append(ForecastItem(
                    date: dateString,
                    time: timeString,
                    category: "POP",
                    value: String(Int.random(in: 0...100))
                ))

                // PTY (강수형태)
                dummyItems.append(ForecastItem(
                    date: dateString,
                    time: timeString,
                    category: "PTY",
                    value: String(Int.random(in: 0...3))
                ))
            }
        }

        return Just(.success(dummyItems))
            .delay(for: .seconds(0.5), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
