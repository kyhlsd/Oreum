//
//  GetTrackingStatusUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/2/25.
//

import Foundation
import Combine

public protocol GetTrackingStatusUseCase {
    func execute() -> AnyPublisher<Bool, Never>
}

public final class GetTrackingStatusUseCaseImpl: GetTrackingStatusUseCase {
    private let repository: TrackActivityRepository

    public init(repository: TrackActivityRepository) {
        self.repository = repository
    }

    public func execute() -> AnyPublisher<Bool, Never> {
        return repository.isTracking()
    }
}
