//
//  DeleteRecentSearchUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/6/25.
//

import Combine

public protocol DeleteRecentSearchUseCase {
    func execute(keyword: String) -> AnyPublisher<Result<Void, Error>, Never>
}

public final class DeleteRecentSearchUseCaseImpl: DeleteRecentSearchUseCase {
    private let repository: RecentSearchRepository

    public init(repository: RecentSearchRepository) {
        self.repository = repository
    }

    public func execute(keyword: String) -> AnyPublisher<Result<Void, Error>, Never> {
        repository.delete(keyword: keyword)
    }
}
