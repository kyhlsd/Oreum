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

    public func fetchAll() -> AnyPublisher<[RecentSearch], Error> {
        let sorted = recentSearches.sorted { $0.searchedAt > $1.searchedAt }
        return Just(sorted)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    public func save(keyword: String) -> AnyPublisher<Void, Error> {
        recentSearches.removeAll { $0.keyword == keyword }
        let newSearch = RecentSearch(keyword: keyword, searchedAt: Date())
        recentSearches.append(newSearch)
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    public func delete(keyword: String) -> AnyPublisher<Void, Error> {
        recentSearches.removeAll { $0.keyword == keyword }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    public func deleteAll() -> AnyPublisher<Void, Error> {
        recentSearches.removeAll()
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
