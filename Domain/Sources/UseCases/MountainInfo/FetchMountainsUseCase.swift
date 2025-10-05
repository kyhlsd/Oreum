//
//  FetchMountainsUseCase.swift
//  Domain
//
//  Created by 김영훈 on 9/30/25.
//

import Combine

public protocol FetchMountainsUseCase {
    func execute(keyword: String) -> AnyPublisher<[MountainInfo], Error>
}

public final class FetchMountainsUseCaseImpl: FetchMountainsUseCase {
    private let repository: MountainInfoRepository

    public init(repository: MountainInfoRepository) {
        self.repository = repository
    }

    public func execute(keyword: String) -> AnyPublisher<[MountainInfo], Error> {
        return repository.fetchMountains(keyword: keyword)
    }
}
