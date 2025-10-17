//
//  GetCurrentActivityDataUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/2/25.
//

import Foundation
import Combine

public protocol GetCurrentActivityDataUseCase {
    func execute() -> AnyPublisher<Result<(time: TimeInterval, steps: Int, distance: Int), Error>, Never>
}

public final class GetCurrentActivityDataUseCaseImpl: GetCurrentActivityDataUseCase {
    private let repository: TrackActivityRepository

    public init(repository: TrackActivityRepository) {
        self.repository = repository
    }

    public func execute() -> AnyPublisher<Result<(time: TimeInterval, steps: Int, distance: Int), Error>, Never> {
        return repository.getCurrentActivityData()
    }
}
