//
//  RealmRecentSearchRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 10/6/25.
//

import Foundation
import Combine
import RealmSwift
import Domain

public final class RealmRecentSearchRepositoryImpl: RecentSearchRepository {

    private let realm: Realm

    public init() throws {
        self.realm = try Realm()
    }

    public func fetchAll() -> AnyPublisher<[RecentSearch], Error> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.failure(NSError(domain: "RealmRecentSearchRepositoryImpl", code: -1)))
                return
            }

            let results = realm.objects(RecentSearchRealm.self)
                .sorted(byKeyPath: "searchedAt", ascending: false)
                .map { $0.toDomain() }

            promise(.success(Array(results)))
        }
        .eraseToAnyPublisher()
    }

    public func save(keyword: String) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.failure(NSError(domain: "RealmRecentSearchRepositoryImpl", code: -1)))
                return
            }

            do {
                try realm.write {
                    if let existing = self.realm.object(ofType: RecentSearchRealm.self, forPrimaryKey: keyword) {
                        self.realm.delete(existing)
                    }
                    let recentSearch = RecentSearchRealm(keyword: keyword, searchedAt: Date())
                    self.realm.add(recentSearch)
                }
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    public func delete(keyword: String) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.failure(NSError(domain: "RealmRecentSearchRepositoryImpl", code: -1)))
                return
            }

            guard let recentSearch = realm.object(ofType: RecentSearchRealm.self, forPrimaryKey: keyword) else {
                promise(.failure(NSError(domain: "RealmRecentSearchRepositoryImpl", code: -2, userInfo: [NSLocalizedDescriptionKey: "Recent search not found"])))
                return
            }

            do {
                try realm.write {
                    self.realm.delete(recentSearch)
                }
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    public func deleteAll() -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.failure(NSError(domain: "RealmRecentSearchRepositoryImpl", code: -1)))
                return
            }

            do {
                try realm.write {
                    let allRecentSearches = self.realm.objects(RecentSearchRealm.self)
                    self.realm.delete(allRecentSearches)
                }
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
