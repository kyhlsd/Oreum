//
//  SaveRecordImageUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/4/25.
//

import Foundation
import Combine

public protocol SaveRecordImageUseCase {
    func execute(recordID: String, imageData: Data) -> AnyPublisher<String, Error>
}

public final class SaveRecordImageUseCaseImpl: SaveRecordImageUseCase {

    private let repository: RecordImageRepository

    public init(repository: RecordImageRepository) {
        self.repository = repository
    }

    public func execute(recordID: String, imageData: Data) -> AnyPublisher<String, Error> {
        return repository.saveImage(recordID: recordID, imageData: imageData)
    }
}
