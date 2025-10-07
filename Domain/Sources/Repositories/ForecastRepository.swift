//
//  ForecastRepository.swift
//  Domain
//
//  Created by 김영훈 on 10/7/25.
//

import Combine

public protocol ForecastRepository {
    func fetchShortTermForecast(longitude: Double, latitude: Double) -> AnyPublisher<Result<[DailyForecast], Error>, Never>
}
