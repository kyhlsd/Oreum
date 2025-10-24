//
//  FetchMountainImageUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/25/25.
//

import Foundation
import Combine

public protocol FetchMountainImageUseCase {
    func execute(id: Int) -> AnyPublisher<Result<[URL], Error>, Never>
}

public final class FetchMountainImageUseCaseImpl: FetchMountainImageUseCase {
    
    private let repository: MountainInfoRepository
    
    public init(repository: MountainInfoRepository) {
        self.repository = repository
    }
    
    public func execute(id: Int) -> AnyPublisher<Result<[URL], any Error>, Never> {
        return repository.fetchImage(id: id)
    }
    
}
