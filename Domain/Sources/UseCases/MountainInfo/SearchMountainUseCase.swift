//
//  FetchMountainUseCase.swift
//  Domain
//
//  Created by 김영훈 on 9/30/25.
//

import Combine

public protocol SearchMountainUseCase {
    func execute(keyword: String, page: Int) -> AnyPublisher<Result<MountainResponse, Error>, Never>
}

public final class SearchMountainUseCaseImpl: SearchMountainUseCase {
    private let repository: MountainInfoRepository

    public init(repository: MountainInfoRepository) {
        self.repository = repository
    }

    public func execute(keyword: String, page: Int) -> AnyPublisher<Result<MountainResponse, Error>, Never> {
        return repository.searchMountain(keyword: keyword, page: page)
    }

}
