//
//  DeleteClimbRecordUseCase.swift
//  Domain
//
//  Created by 김영훈 on 9/29/25.
//

import Combine

public protocol DeleteClimbRecordUseCase {
    func execute(recordID: String) -> AnyPublisher<Void, Error>
}

public final class DeleteClimbRecordUseCaseImpl: DeleteClimbRecordUseCase {
    private let repository: ClimbRecordRepository
    
    public init(repository: ClimbRecordRepository) {
        self.repository = repository
    }
    
    public func execute(recordID: String) -> AnyPublisher<Void, any Error> {
        repository.delete(recordID: recordID)
    }
}
