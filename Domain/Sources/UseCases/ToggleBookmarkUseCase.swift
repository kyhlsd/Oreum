//
//  ToggleBookmarkUseCase.swift
//  Domain
//
//  Created by 김영훈 on 9/27/25.
//

import Combine

public protocol ToggleBookmarkUseCase {
    func execute(recordID: String) -> AnyPublisher<Void, Error>
}

public final class ToggleBookmarkUseCaseImpl: ToggleBookmarkUseCase {
    private let repository: ClimbRecordRepository
    
    public init(repository: ClimbRecordRepository) {
        self.repository = repository
    }
    
    public func execute(recordID: String) -> AnyPublisher<Void, Error> {
        repository.toggleBookmark(recordID: recordID)
    }
}
