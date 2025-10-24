//
//  FetchMountainInfoUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/24/25.
//

import Foundation
import Combine

public protocol FetchMountainInfoUseCase {
    func execute(name: String, mountainID: Int) -> AnyPublisher<Result<MountainInfo, Error>, Never>
}

public final class FetchMountainInfoUseCaseImpl: FetchMountainInfoUseCase {
    
    private let repository: MountainInfoRepository

    public init(repository: MountainInfoRepository) {
        self.repository = repository
    }
    
    public func execute(name: String, mountainID: Int) -> AnyPublisher<Result<MountainInfo, any Error>, Never> {
        return repository.searchMountain(keyword: name, page: 1)
            .map { result in
                switch result {
                case .success(let response):
                    let mountains = response.body.items.item
                    let filtered = mountains
                        .filter { $0.id == mountainID }
                    
                    if let mountain = filtered.first {
                        return .success(mountain)
                    } else {
                        return .failure(NSError(domain: "FetchMountainUseCaseImpl", code: -1, userInfo: [NSLocalizedDescriptionKey: "산 정보를 찾을 수 없습니다."]))
                    }
                case .failure(let error):
                    return .failure(error)
                }
            }
            .eraseToAnyPublisher()
    }
}
