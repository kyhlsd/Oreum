//
//  GetActivityLogsUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/1/25.
//

import Foundation
import Combine

public protocol GetActivityLogsUseCase {
    func execute() -> AnyPublisher<Result<[ActivityLog], Error>, Never>
}

public final class GetActivityLogsUseCaseImpl: GetActivityLogsUseCase {
    private let repository: TrackActivityRepository

    public init(repository: TrackActivityRepository) {
        self.repository = repository
    }

    public func execute() -> AnyPublisher<Result<[ActivityLog], Error>, Never> {
        return repository.getActivityLogs()
    }
}
