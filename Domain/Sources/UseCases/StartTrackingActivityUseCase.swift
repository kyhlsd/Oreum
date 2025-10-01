//
//  StartTrackingActivityUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/1/25.
//

import Foundation

public protocol StartTrackingActivityUseCase {
    func execute(startDate: Date)
}

public final class StartTrackingActivityUseCaseImpl: StartTrackingActivityUseCase {
    private let repository: TrackActivityRepository

    public init(repository: TrackActivityRepository) {
        self.repository = repository
    }

    public func execute(startDate: Date) {
        repository.startTracking(startDate: startDate)
    }
}
