//
//  MountainInfoRepository.swift
//  Domain
//
//  Created by 김영훈 on 9/30/25.
//

import Combine

public protocol MountainInfoRepository {
    func searchMountain(keyword: String, page: Int) -> AnyPublisher<Result<MountainResponse, Error>, Never>
}
