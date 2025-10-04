//
//  StopTrackingActivityUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/1/25.
//

import Foundation

public protocol StopTrackingActivityUseCase {
    func execute(clearData: Bool)
}

public final class StopTrackingActivityUseCaseImpl: StopTrackingActivityUseCase {
    private let repository: TrackActivityRepository

    public init(repository: TrackActivityRepository) {
        self.repository = repository
    }

    public func execute(clearData: Bool = true) {
        repository.stopTracking()
        if clearData {
            repository.clearTrackingData()
        }
    }
}
