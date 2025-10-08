//
//  RecentSearchRepository.swift
//  Domain
//
//  Created by 김영훈 on 10/6/25.
//

import Combine

public protocol RecentSearchRepository {
    func fetchAll() -> AnyPublisher<[RecentSearch], Error>
    func save(keyword: String) -> AnyPublisher<Void, Error>
    func delete(keyword: String) -> AnyPublisher<Void, Error>
    func deleteAll() -> AnyPublisher<Void, Error>
}
