//
//  SaveRecentSearchUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/6/25.
//

import Combine

public protocol SaveRecentSearchUseCase {
    func execute(keyword: String) -> AnyPublisher<Result<Void, Error>, Never>
}

public final class SaveRecentSearchUseCaseImpl: SaveRecentSearchUseCase {
    private let repository: RecentSearchRepository

    public init(repository: RecentSearchRepository) {
        self.repository = repository
    }

    public func execute(keyword: String) -> AnyPublisher<Result<Void, Error>, Never> {
        repository.save(keyword: keyword)
    }
}
