//
//  ErrorRecentSearchRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 10/6/25.
//

import Foundation
import Combine
import Domain

// Realm 생성 실패 시 반환
public final class ErrorRecentSearchRepositoryImpl: RecentSearchRepository {
    
    private let error = NSError(domain: "ErrorRecentSearchRepositoryImpl", code: -1, userInfo: [NSLocalizedDescriptionKey: "Repository is unavailable"])
    
    public init() {}
    
    public func fetchAll() -> AnyPublisher<[Domain.RecentSearch], any Error> {
        return Fail(error: error)
            .eraseToAnyPublisher()
    }
    
    public func save(keyword: String) -> AnyPublisher<Void, any Error> {
        return Fail(error: error)
            .eraseToAnyPublisher()
    }
    
    public func delete(keyword: String) -> AnyPublisher<Void, any Error> {
        return Fail(error: error)
            .eraseToAnyPublisher()
    }
    
    public func deleteAll() -> AnyPublisher<Void, any Error> {
        return Fail(error: error)
            .eraseToAnyPublisher()
    }
    
}
