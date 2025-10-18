//
//  RemoveImageFromRecordUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/4/25.
//

import Foundation
import Combine

public protocol RemoveImageFromRecordUseCase {
    func execute(imageID: String) -> AnyPublisher<Result<Void, Error>, Never>
}

public final class RemoveImageFromRecordUseCaseImpl: RemoveImageFromRecordUseCase {

    private let repository: ClimbRecordRepository

    public init(repository: ClimbRecordRepository) {
        self.repository = repository
    }

    public func execute(imageID: String) -> AnyPublisher<Result<Void, Error>, Never> {
        return repository.removeImage(imageID: imageID)
    }
}
