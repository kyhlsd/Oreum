//
//  DeleteRecordImageUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/4/25.
//

import Foundation
import Combine

public protocol DeleteRecordImageUseCase {
    func execute(imageID: String) -> AnyPublisher<Result<Void, Error>, Never>
}

public final class DeleteRecordImageUseCaseImpl: DeleteRecordImageUseCase {

    private let repository: RecordImageRepository

    public init(repository: RecordImageRepository) {
        self.repository = repository
    }

    public func execute(imageID: String) -> AnyPublisher<Result<Void, Error>, Never> {
        return repository.deleteImage(imageID: imageID)
    }
}
