//
//  RecentSearchRepository.swift
//  Domain
//
//  Created by 김영훈 on 10/6/25.
//

import Combine

public protocol RecentSearchRepository {
    func fetchAll() -> AnyPublisher<Result<[RecentSearch], Error>, Never>
    func save(keyword: String) -> AnyPublisher<Result<Void, Error>, Never>
    func delete(keyword: String) -> AnyPublisher<Result<Void, Error>, Never>
    func deleteAll() -> AnyPublisher<Result<Void, Error>, Never>
}
