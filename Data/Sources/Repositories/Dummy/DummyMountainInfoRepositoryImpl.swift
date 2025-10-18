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

    // Dummy data
    private let dummyMountainInfos = MountainInfo.dummy

    public init() {}

    public func fetchMountainInfo(name: String, height: Int) -> AnyPublisher<Result<MountainInfo, Error>, Never> {
        let mountains = dummyMountainInfos.filter {
            $0.name.first == name.first &&
            abs($0.height - height) < 3
        }

        if let mountainInfo = mountains.first {
            return Just(.success(mountainInfo))
                .eraseToAnyPublisher()
        } else {
            return Just(.failure(JSONError.mountainNotFound))
                .eraseToAnyPublisher()
        }
    }
    
    public func fetchMountains(keyword: String) -> AnyPublisher<Result<[MountainInfo], Error>, Never> {
        guard !keyword.isEmpty else {
            return Just(.success([]))
                .eraseToAnyPublisher()
        }

        let filtered = dummyMountainInfos.filter { mountain in
            mountain.name.localizedCaseInsensitiveContains(keyword) ||
            mountain.address.localizedCaseInsensitiveContains(keyword)
        }

        return Just(.success(filtered))
            .eraseToAnyPublisher()
    }
}
