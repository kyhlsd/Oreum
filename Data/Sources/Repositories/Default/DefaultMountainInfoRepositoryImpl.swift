//
//  DefaultMountainInfoRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 10/23/25.
//

import Foundation
import Combine
import Domain

public final class DefaultMountainInfoRepositoryImpl: MountainInfoRepository {

    public init() {}

    // 산 검색
    public func searchMountain(keyword: String, page: Int) -> AnyPublisher<Result<MountainResponse, Error>, Never> {
        return NetworkManager.shared.callXMLRequest(url: MountainRouter.getMountainInfo(keyword: keyword, page: page), type: MountainResponseDTO.self)
            .map { result in
                switch result {
                case .success(let dto):
                    let items = dto.toDomain()
                    return .success(items)
                case .failure(let apiError):
                    return .failure(apiError)
                }
            }
            .eraseToAnyPublisher()

    }
    
}
