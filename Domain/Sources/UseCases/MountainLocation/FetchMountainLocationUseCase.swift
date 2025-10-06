//
//  FetchMountainLocationUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/4/25.
//

import Combine

public protocol FetchMountainLocationUseCase {
    func execute() -> AnyPublisher<[MountainLocation], Error>
}

public final class FetchMountainLocationUseCaseImpl: FetchMountainLocationUseCase {
    private let repository: MountainLocationRepository
    
    public init(repository: MountainLocationRepository) {
        self.repository = repository
    }
    
    public func execute() -> AnyPublisher<[MountainLocation], any Error> {
        return repository.fetchMountainLocations()
    }
}
