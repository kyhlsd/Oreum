//
//  TempMountainRepository.swift
//  Domain
//
//  Created by 김영훈 on 9/30/25.
//

import Combine

public protocol MountainInfoRepository {
    func fetchMountains(keyword: String) -> AnyPublisher<[MountainInfo], Error>
}
