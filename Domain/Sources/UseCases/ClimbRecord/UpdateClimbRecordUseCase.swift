//
//  UpdateClimbRecordUseCase.swift
//  Domain
//
//  Created by 김영훈 on 9/29/25.
//

import Combine

public protocol UpdateClimbRecordUseCase {
    func execute(recordID: String, rating: Int, comment: String) -> AnyPublisher<Result<Void, Error>, Never>
}

public final class UpdateClimbRecordUseCaseImpl: UpdateClimbRecordUseCase {
    private let repository: ClimbRecordRepository

    public init(repository: ClimbRecordRepository) {
        self.repository = repository
    }

    public func execute(recordID: String, rating: Int, comment: String) -> AnyPublisher<Result<Void, Error>, Never> {
        return repository.update(recordID: recordID, rating: rating, comment: comment)
    }
}
