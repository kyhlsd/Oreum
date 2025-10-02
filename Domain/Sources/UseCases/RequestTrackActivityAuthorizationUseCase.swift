//
//  RequestTrackActivityAuthorizationUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/1/25.
//

import Foundation
import Combine

public protocol RequestTrackActivityAuthorizationUseCase {
    func execute() -> AnyPublisher<Bool, Error>
}

public final class RequestTrackActivityAuthorizationUseCaseImpl: RequestTrackActivityAuthorizationUseCase {
    private let repository: TrackActivityRepository

    public init(repository: TrackActivityRepository) {
        self.repository = repository
    }

    public func execute() -> AnyPublisher<Bool, Error> {
        return repository.requestAuthorization()
    }
}
