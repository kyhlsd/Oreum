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
    
    public func fetchCoordinate(address: String) -> AnyPublisher<Result<Coordinate, Error>, Never> {
        return NetworkManager.shared
            .callRequest(url: GeocoderRouter.getCoordinate(address: address), type: CoordinateDTO.self)
            .map { result in
                switch result {
                case .success(let dto):
                    if let coordinate = dto.toDomain() {
                        return .success(coordinate)
                    } else {
                        return .failure(APIError.some(message: "주소 변환에 실패했습니다."))
                    }
                case .failure(let apiError):
                    return .failure(apiError)
                }
            }
            .eraseToAnyPublisher()
    }
}
