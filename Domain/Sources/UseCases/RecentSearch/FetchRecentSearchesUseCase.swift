//
//  FetchRecentSearchesUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/6/25.
//

import Combine

public protocol FetchRecentSearchesUseCase {
    func execute() -> AnyPublisher<[RecentSearch], Error>
}

public final class FetchRecentSearchesUseCaseImpl: FetchRecentSearchesUseCase {
    private let repository: RecentSearchRepository

    public init(repository: RecentSearchRepository) {
        self.repository = repository
    }

    public func execute() -> AnyPublisher<[RecentSearch], Error> {
        repository.fetchAll()
    }
}
