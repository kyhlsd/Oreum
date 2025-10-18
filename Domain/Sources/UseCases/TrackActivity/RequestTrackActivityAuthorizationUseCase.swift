//
//  RequestTrackActivityAuthorizationUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/1/25.
//

import Foundation
import Combine

public protocol RequestTrackActivityAuthorizationUseCase {
    func execute() -> AnyPublisher<Result<Bool, Error>, Never>
}

public final class RequestTrackActivityAuthorizationUseCaseImpl: RequestTrackActivityAuthorizationUseCase {
    private let repository: TrackActivityRepository

    public init(repository: TrackActivityRepository) {
        self.repository = repository
    }

    public func execute() -> AnyPublisher<Result<Bool, Error>, Never> {
        return repository.requestAuthorization()
    }
}
