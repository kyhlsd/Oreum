//
//  DefaultGeocodeRepositoryImpl.swift
//  Domain
//
//  Created by 김영훈 on 10/6/25.
//

import Foundation
import Combine
import Domain

public final class DefaultGeocodeRepositoryImpl: GeocodeRepository {
    
    public init() {}
    
    // Geocoding
    public func fetchCoordinate(address: String) -> AnyPublisher<Result<Coordinate, Error>, Never> {
        if address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return Just(.failure(APIError.some(message: "주소 값이 없습니다."))).eraseToAnyPublisher()
        }
        return NetworkManager.shared
            .callRequest(url: GeocoderRouter.getCoordinate(address: address), type: CoordinateDTO.self)
            .map { result in
                switch result {
                case .success(let dto):
                    if let coordinate = dto.toDomain() {
                        return .success(coordinate)
                    } else {
                        return .failure(APIError.unknown)
                    }
                case .failure(let apiError):
                    return .failure(apiError)
                }
            }
            .eraseToAnyPublisher()
    }
}
