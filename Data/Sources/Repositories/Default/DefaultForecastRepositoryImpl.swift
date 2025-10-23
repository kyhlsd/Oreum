//
//  DefaultForecastRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 10/7/25.
//

import Foundation
import Combine
import Domain

public final class DefaultForecastRepositoryImpl: ForecastRepository {

    public init() {}

    // 단기예보
    public func fetchShortTermForecast(nx: Int, ny: Int) -> AnyPublisher<Result<[ForecastItem], Error>, Never> {
        return NetworkManager.shared
            .callRequest(url: ForecastRouter.getShortTermForecast(nx: nx, ny: ny), type: ShortTermForecastDTO.self)
            .map { result in
                switch result {
                case .success(let dto):
                    let items = dto.response.body.items.item.map { $0.toDomain() }
                    return .success(items)
                case .failure(let apiError):
                    return .failure(apiError)
                }
            }
            .eraseToAnyPublisher()
    }

}
