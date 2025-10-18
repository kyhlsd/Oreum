//
//  SaveClimbRecordUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/2/25.
//

import Foundation
import Combine

public protocol SaveClimbRecordUseCase {
    func execute(record: ClimbRecord) -> AnyPublisher<Result<ClimbRecord, Error>, Never>
}

public final class SaveClimbRecordUseCaseImpl: SaveClimbRecordUseCase {
    private let repository: ClimbRecordRepository

    public init(repository: ClimbRecordRepository) {
        self.repository = repository
    }

    public func execute(record: ClimbRecord) -> AnyPublisher<Result<ClimbRecord, Error>, Never> {
        return repository.save(record: record)
    }
}
