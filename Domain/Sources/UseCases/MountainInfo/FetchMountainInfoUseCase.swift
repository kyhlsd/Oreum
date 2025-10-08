//
//  FetchMountainInfoUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/5/25.
//

import Combine

public protocol FetchMountainInfoUseCase {
    func execute(name: String, height: Int) -> AnyPublisher<MountainInfo, Error>
}

public final class FetchMountainInfoUseCaseImpl: FetchMountainInfoUseCase {
    private let repository: MountainInfoRepository
    
    public init(repository: MountainInfoRepository) {
        self.repository = repository
    }
    
    public func execute(name: String, height: Int) -> AnyPublisher<MountainInfo, any Error> {
        return repository.fetchMountainInfo(name: name, height: height)
    }
}
