//
//  SaveRecordImageUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/4/25.
//

import Foundation
import Combine

public protocol SaveRecordImageUseCase {
    func execute(imageData: Data) -> AnyPublisher<Result<String, Error>, Never>
}

public final class SaveRecordImageUseCaseImpl: SaveRecordImageUseCase {

    private let repository: RecordImageRepository

    public init(repository: RecordImageRepository) {
        self.repository = repository
    }

    public func execute(imageData: Data) -> AnyPublisher<Result<String, Error>, Never> {
        return repository.saveImage(imageData: imageData)
    }
}
