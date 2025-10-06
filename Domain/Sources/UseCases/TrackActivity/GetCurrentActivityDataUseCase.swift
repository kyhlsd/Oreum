//
//  GetCurrentActivityDataUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/2/25.
//

import Foundation
import Combine

public protocol GetCurrentActivityDataUseCase {
    func execute() -> AnyPublisher<(time: TimeInterval, steps: Int, distance: Int), Error>
}

public final class GetCurrentActivityDataUseCaseImpl: GetCurrentActivityDataUseCase {
    private let repository: TrackActivityRepository

    public init(repository: TrackActivityRepository) {
        self.repository = repository
    }

    public func execute() -> AnyPublisher<(time: TimeInterval, steps: Int, distance: Int), Error> {
        return repository.getCurrentActivityData()
    }
}
