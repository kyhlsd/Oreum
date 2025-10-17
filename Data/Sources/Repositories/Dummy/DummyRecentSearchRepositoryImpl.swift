//
//  DummyRecentSearchRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 10/6/25.
//

import Foundation
import Combine
import Domain

public final class DummyRecentSearchRepositoryImpl: RecentSearchRepository {

    public static let shared = DummyRecentSearchRepositoryImpl()

    private var recentSearches: [RecentSearch] = []

    private init() {}

    public func fetchAll() -> AnyPublisher<Result<[RecentSearch], Error>, Never> {
        let sorted = recentSearches.sorted { $0.searchedAt > $1.searchedAt }
        return Just(.success(sorted))
            .eraseToAnyPublisher()
    }

    public func save(keyword: String) -> AnyPublisher<Result<Void, Error>, Never> {
        recentSearches.removeAll { $0.keyword == keyword }
        let newSearch = RecentSearch(id: UUID().uuidString, keyword: keyword, searchedAt: Date())
        recentSearches.append(newSearch)
        return Just(.success(()))
            .eraseToAnyPublisher()
    }

    public func delete(keyword: String) -> AnyPublisher<Result<Void, Error>, Never> {
        recentSearches.removeAll { $0.keyword == keyword }
        return Just(.success(()))
            .eraseToAnyPublisher()
    }

    public func deleteAll() -> AnyPublisher<Result<Void, Error>, Never> {
        recentSearches.removeAll()
        return Just(.success(()))
            .eraseToAnyPublisher()
    }
}
