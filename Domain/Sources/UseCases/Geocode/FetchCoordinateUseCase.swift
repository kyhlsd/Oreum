//
//  FetchCoordinateUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/6/25.
//

import Foundation
import Combine

public protocol FetchCoordinateUseCase {
    func execute(address: String) -> AnyPublisher<Result<Coordinate, Error>, Never>
}

public final class FetchCoordinateUseCaseImpl: FetchCoordinateUseCase {

    private let repository: GeocodeRepository

    public init(repository: GeocodeRepository) {
        self.repository = repository
    }

    public func execute(address: String) -> AnyPublisher<Result<Coordinate, any Error>, Never> {
        // 입력 검증
        if address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return Just(.failure(NSError(domain: "FetchCoordinateUseCaseImpl", code: -1, userInfo: [NSLocalizedDescriptionKey: "주소 값이 없습니다."])))
                .eraseToAnyPublisher()
        }

        return repository.fetchCoordinate(address: address)
    }
}
