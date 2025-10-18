//
//  FetchMountainsUseCase.swift
//  Domain
//
//  Created by 김영훈 on 9/30/25.
//

import Combine

public protocol FetchMountainsUseCase {
    func execute(keyword: String) -> AnyPublisher<Result<[MountainInfo], Error>, Never>
}

public final class FetchMountainsUseCaseImpl: FetchMountainsUseCase {
    private let repository: MountainInfoRepository

    public init(repository: MountainInfoRepository) {
        self.repository = repository
    }

    public func execute(keyword: String) -> AnyPublisher<Result<[MountainInfo], Error>, Never> {
        return repository.fetchMountains(keyword: keyword)
    }
}
