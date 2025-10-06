//
//  GeocodeRepository.swift
//  Domain
//
//  Created by 김영훈 on 10/6/25.
//

import Combine

public protocol GeocodeRepository {
    func fetchCoordinate(address: String) -> AnyPublisher<Result<Coordinate, Error>, Never>
}
