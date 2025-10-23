//
//  DefaultMountainInfoRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 10/23/25.
//

import Foundation
import Combine
import Domain

//public final class DefaultMountainInfoRepositoryImpl: MountainInfoRepository {
//
//    public init() {}
//
//    // 산 검색
//    public func fetchMountains(keyword: String) -> AnyPublisher<Result<[MountainInfo], Error>, Never> {
//
//        guard !keyword.isEmpty else {
//            return Just(.success([]))
//                .eraseToAnyPublisher()
//        }
//
//        
//    }
//
//    // TODO: 산 코드 기반으로 수정하고, Usecase에서 처리하기
//    // 산 상세 정보 불러오기
//    public func fetchMountainInfo(name: String, height: Int) -> AnyPublisher<Result<Domain.MountainInfo, any Error>, Never> {
//        
//    }
//    
//}
