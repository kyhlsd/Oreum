//
//  FetchClimbRecordUseCase.swift
//  Domain
//
//  Created by 김영훈 on 9/27/25.
//

import Combine

public protocol FetchClimbRecordUseCase {
    func execute(keyword: String, isOnlyBookmarked: Bool) -> AnyPublisher<[ClimbRecord], Error>
}

public final class FetchClimbRecordUseCaseImpl: FetchClimbRecordUseCase {
    private let repository: ClimbRecordRepository
    
    public init(repository: ClimbRecordRepository) {
        self.repository = repository
    }
    
    public func execute(keyword: String, isOnlyBookmarked: Bool) -> AnyPublisher<[ClimbRecord], Error> {
        repository.fetch(keyword: keyword, isOnlyBookmarked: isOnlyBookmarked)
    }
}
