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
        return repository.fetchCoordinate(address: address)
    }
}
