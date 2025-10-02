//
//  GetClimbingMountainUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/2/25.
//

import Foundation

public protocol GetClimbingMountainUseCase {
    func execute() -> Mountain?
}

public final class GetClimbingMountainUseCaseImpl: GetClimbingMountainUseCase {
    private let repository: TrackActivityRepository

    public init(repository: TrackActivityRepository) {
        self.repository = repository
    }

    public func execute() -> Mountain? {
        return repository.getClimbingMountain()
    }
}
