//
//  FetchClimbRecordUseCase.swift
//  Domain
//
//  Created by 김영훈 on 9/27/25.
//

import Combine

public protocol FetchClimbRecordUseCase {
    func execute(keyword: String, isOnlyBookmarked: Bool) -> AnyPublisher<Result<[ClimbRecord], Error>, Never>
}

public final class FetchClimbRecordUseCaseImpl: FetchClimbRecordUseCase {
    private let repository: ClimbRecordRepository

    public init(repository: ClimbRecordRepository) {
        self.repository = repository
    }

    public func execute(keyword: String, isOnlyBookmarked: Bool) -> AnyPublisher<Result<[ClimbRecord], Error>, Never> {
        repository.fetch(keyword: keyword, isOnlyBookmarked: isOnlyBookmarked)
    }
}
