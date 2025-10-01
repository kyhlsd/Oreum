//
//  RequestHealthKitAuthorizationUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/1/25.
//

import Foundation
import Combine

public protocol RequestHealthKitAuthorizationUseCase {
    func execute() -> AnyPublisher<Bool, Error>
}

public final class RequestHealthKitAuthorizationUseCaseImpl: RequestHealthKitAuthorizationUseCase {
    private let repository: TrackActivityRepository

    public init(repository: TrackActivityRepository) {
        self.repository = repository
    }

    public func execute() -> AnyPublisher<Bool, Error> {
        return repository.requestAuthorization()
    }
}
