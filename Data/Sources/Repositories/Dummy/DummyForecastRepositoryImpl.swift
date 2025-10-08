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

    public init() {}

    public func fetchShortTermForecast(longitude: Double, latitude: Double) -> AnyPublisher<Result<[DailyForecast], Error>, Never> {
        let today = Calendar.current.startOfDay(for: Date())

        let dummyForecasts = (0..<7).map { dayOffset in
            let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: today) ?? today
            let minTemp = Double.random(in: 10...15)
            let maxTemp = Double.random(in: 20...28)
            let pop = Int.random(in: 0...100)
            let pty = Int.random(in: 0...3)

            return DailyForecast(
                date: date,
                minTemp: minTemp,
                maxTemp: maxTemp,
                pop: pop,
                pty: pty
            )
        }

        return Just(.success(dummyForecasts))
            .delay(for: .seconds(0.5), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
