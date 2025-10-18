//
//  ClearRecentSearchesUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/6/25.
//

import Combine

public protocol ClearRecentSearchesUseCase {
    func execute() -> AnyPublisher<Result<Void, Error>, Never>
}

public final class ClearRecentSearchesUseCaseImpl: ClearRecentSearchesUseCase {
    private let repository: RecentSearchRepository

    public init(repository: RecentSearchRepository) {
        self.repository = repository
    }

    public func execute() -> AnyPublisher<Result<Void, Error>, Never> {
        repository.deleteAll()
    }
}
