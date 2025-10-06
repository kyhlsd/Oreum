//
//  SaveRecentSearchUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/6/25.
//

import Combine

public protocol SaveRecentSearchUseCase {
    func execute(keyword: String) -> AnyPublisher<Void, Error>
}

public final class SaveRecentSearchUseCaseImpl: SaveRecentSearchUseCase {
    private let repository: RecentSearchRepository

    public init(repository: RecentSearchRepository) {
        self.repository = repository
    }

    public func execute(keyword: String) -> AnyPublisher<Void, Error> {
        repository.save(keyword: keyword)
    }
}
