//
//  DummyMountainInfoRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 9/30/25.
//

import Foundation
import Combine
import Domain

public final class DummyMountainInfoRepositoryImpl: MountainInfoRepository {

    public init() {}
    
    public func searchMountain(keyword: String, page: Int) -> AnyPublisher<Result<MountainResponse, Error>, Never> {
        return Just(.success(MountainResponse.dummy))
            .eraseToAnyPublisher()
    }

    public func fetchImage(id: Int) -> AnyPublisher<Result<[URL], any Error>, Never> {
        let urls = [String](repeating: "https://picsum.photos/200/300", count: 3)
            .compactMap { URL(string: $0) }
        return Just(.success(urls))
            .eraseToAnyPublisher()
    }
}
