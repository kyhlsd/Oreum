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

    public func fetchMountainInfo(name: String, height: Int) -> AnyPublisher<Domain.MountainInfo, any Error> {
        let mountains = dummyMountainInfos.filter {
            $0.name.first == name.first &&
            abs($0.height - height) < 3
        }
        
        if let mountainInfo = mountains.first {
            return Just(mountainInfo)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: NSError(domain: "DummyMountainInfoRepositoryImpl", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mountain information not found"]))
                .eraseToAnyPublisher()
        }
    }
    
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
