//
//  FetchRecordImageUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/4/25.
//

import Foundation
import Combine

public protocol FetchRecordImageUseCase {
    func execute(imageID: String) -> AnyPublisher<Data, Error>
}

public final class FetchRecordImageUseCaseImpl: FetchRecordImageUseCase {

    private let repository: RecordImageRepository

    public init(repository: RecordImageRepository) {
        self.repository = repository
    }

    public func execute(imageID: String) -> AnyPublisher<Data, Error> {
        return repository.fetchImage(imageID: imageID)
    }
}
