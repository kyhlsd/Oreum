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

    public func fetchImage(id: Int) -> AnyPublisher<Result<[String], any Error>, Never> {
        let urlStrings = [String](repeating: "https://picsum.photos/200/300", count: 3)
        return Just(.success(urlStrings))
            .eraseToAnyPublisher()
    }
}
