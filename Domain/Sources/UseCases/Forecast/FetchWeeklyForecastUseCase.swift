//
//  FetchWeeklyForecastUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/7/25.
//

import Foundation
import Combine

public protocol FetchWeeklyForecastUseCase {
    func execute(longitude: Double, latitude: Double) -> AnyPublisher<Result<[DailyForecast], Error>, Never>
}

public final class FetchWeeklyForecastUseCaseImpl: FetchWeeklyForecastUseCase {
    
    private let repository: ForecastRepository
    
    public init(repository: ForecastRepository) {
        self.repository = repository
    }
    
    public func execute(longitude: Double, latitude: Double) -> AnyPublisher<Result<[DailyForecast], any Error>, Never> {
        return repository.fetchShortTermForecast(longitude: longitude, latitude: latitude)
    }
}
