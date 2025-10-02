//
//  ObserveActivityDataUpdatesUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/2/25.
//

import Foundation
import Combine

public protocol ObserveActivityDataUpdatesUseCase {
    var dataUpdates: AnyPublisher<Void, Never> { get }
}

public final class ObserveActivityDataUpdatesUseCaseImpl: ObserveActivityDataUpdatesUseCase {
    private let repository: TrackActivityRepository

    public init(repository: TrackActivityRepository) {
        self.repository = repository
    }

    public var dataUpdates: AnyPublisher<Void, Never> {
        return repository.dataUpdatePublisher
    }
}
