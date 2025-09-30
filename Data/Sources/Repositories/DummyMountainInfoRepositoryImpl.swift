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

    public func fetchMountains(keyword: String) -> AnyPublisher<[MountainInfo], Error> {
        guard !keyword.isEmpty else {
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        let filtered = dummyMountainInfos.filter { mountain in
            mountain.name.localizedCaseInsensitiveContains(keyword) ||
            mountain.address.localizedCaseInsensitiveContains(keyword)
        }

        return Just(filtered)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
