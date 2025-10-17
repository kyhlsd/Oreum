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

    private let realm: Realm?

    public init() {
        self.realm = try? Realm()
    }

    public func fetchAll() -> AnyPublisher<[RecentSearch], Error> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.failure(RealmError.repositoryDeallocated))
                return
            }

            guard let realm = self.realm else {
                promise(.failure(RealmError.realmInitializationFailed))
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
                promise(.failure(RealmError.repositoryDeallocated))
                return
            }

            guard let realm = self.realm else {
                promise(.failure(RealmError.realmInitializationFailed))
                return
            }

            do {
                try realm.write {
                    let objects = realm.objects(RecentSearchRealm.self).filter( "keyword == %@", keyword )
                    realm.delete(objects)
                    let recentSearch = RecentSearchRealm(keyword: keyword, searchedAt: Date())
                    realm.add(recentSearch)
                }
                promise(.success(()))
            } catch {
                promise(.failure(RealmError.writeTransactionFailed))
            }
        }
        .eraseToAnyPublisher()
    }

    public func delete(keyword: String) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.failure(RealmError.repositoryDeallocated))
                return
            }

            guard let realm = self.realm else {
                promise(.failure(RealmError.realmInitializationFailed))
                return
            }

            let objects = realm.objects(RecentSearchRealm.self).filter("keyword == %@", keyword)

            guard !objects.isEmpty else {
                promise(.failure(RealmError.recordNotFound))
                return
            }

            do {
                try realm.write {
                    realm.delete(objects)
                }
                promise(.success(()))
            } catch {
                promise(.failure(RealmError.writeTransactionFailed))
            }
        }
        .eraseToAnyPublisher()
    }

    public func deleteAll() -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.failure(RealmError.repositoryDeallocated))
                return
            }

            guard let realm = self.realm else {
                promise(.failure(RealmError.realmInitializationFailed))
                return
            }

            do {
                try realm.write {
                    let allRecentSearches = realm.objects(RecentSearchRealm.self)
                    realm.delete(allRecentSearches)
                }
                promise(.success(()))
            } catch {
                promise(.failure(RealmError.writeTransactionFailed))
            }
        }
        .eraseToAnyPublisher()
    }
}
