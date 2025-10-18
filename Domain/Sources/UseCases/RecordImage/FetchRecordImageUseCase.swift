//
//  FetchRecordImageUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/4/25.
//

import Foundation
import Combine

public protocol FetchRecordImageUseCase {
    func execute(imageID: String) -> AnyPublisher<Result<Data, Error>, Never>
}

public final class FetchRecordImageUseCaseImpl: FetchRecordImageUseCase {

    private let repository: RecordImageRepository

    public init(repository: RecordImageRepository) {
        self.repository = repository
    }

    public func execute(imageID: String) -> AnyPublisher<Result<Data, Error>, Never> {
        return repository.fetchImage(imageID: imageID)
    }
}
