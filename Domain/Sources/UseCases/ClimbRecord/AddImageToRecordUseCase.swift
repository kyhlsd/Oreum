//
//  AddImageToRecordUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/4/25.
//

import Foundation
import Combine

public protocol AddImageToRecordUseCase {
    func execute(recordID: String, imageID: String) -> AnyPublisher<Void, Error>
}

public final class AddImageToRecordUseCaseImpl: AddImageToRecordUseCase {

    private let repository: ClimbRecordRepository

    public init(repository: ClimbRecordRepository) {
        self.repository = repository
    }

    public func execute(recordID: String, imageID: String) -> AnyPublisher<Void, Error> {
        return repository.addImage(recordID: recordID, imageID: imageID)
    }
}
