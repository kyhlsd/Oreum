//
//  StartTrackingActivityUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/1/25.
//

import Foundation

public protocol StartTrackingActivityUseCase {
    func execute(startDate: Date, mountain: Mountain)
}

public final class StartTrackingActivityUseCaseImpl: StartTrackingActivityUseCase {
    private let repository: TrackActivityRepository

    public init(repository: TrackActivityRepository) {
        self.repository = repository
    }

    public func execute(startDate: Date, mountain: Mountain) {
        repository.startTracking(startDate: startDate, mountain: mountain)
    }
}
