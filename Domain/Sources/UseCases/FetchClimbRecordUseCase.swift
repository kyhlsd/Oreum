//
//  FetchClimbRecordUseCase.swift
//  Domain
//
//  Created by 김영훈 on 9/27/25.
//

import Combine

public protocol FetchClimbRecordUseCase {
    func execute() -> AnyPublisher<[ClimbRecord], Error>
    func search(keyword: String) -> AnyPublisher<[ClimbRecord], Error>
}

public final class FetchClimbRecordUseCaseImpl: FetchClimbRecordUseCase {
    private let repository: ClimbRecordRepository
    
    public init(repository: ClimbRecordRepository) {
        self.repository = repository
    }
    
    public func execute() -> AnyPublisher<[ClimbRecord], Error> {
        repository.fetchClimbRecords()
    }
    
    public func search(keyword: String) -> AnyPublisher<[ClimbRecord], Error> {
        repository.search(keyword: keyword)
    }
}
