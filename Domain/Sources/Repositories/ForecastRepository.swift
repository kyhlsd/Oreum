//
//  ForecastRepository.swift
//  Domain
//
//  Created by 김영훈 on 10/7/25.
//

import Combine

public protocol ForecastRepository {
    func fetchShortTermForecast(nx: Int, ny: Int) -> AnyPublisher<Result<[ForecastItem], Error>, Never>
}
