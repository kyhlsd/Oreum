//
//  DummyGeocodeRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 10/8/25.
//

import Foundation
import Combine
import Domain

public final class DummyGeocodeRepositoryImpl: GeocodeRepository {

    public init() {}

    public func fetchCoordinate(address: String) -> AnyPublisher<Result<Coordinate, Error>, Never> {
        if address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return Just(.failure(APIError.some(message: "주소 값이 없습니다.")))
                .eraseToAnyPublisher()
        }

        // 더미 좌표 데이터 (서울 주변)
        let dummyCoordinate = Coordinate(
            longitude: Double.random(in: 126.9...127.1),
            latitude: Double.random(in: 37.5...37.6)
        )

        return Just(.success(dummyCoordinate))
            .delay(for: .seconds(0.3), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
