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
        self.realm = RealmHelper.shared
    }

    // 모든 검색어 가져오기
    public func fetch() -> AnyPublisher<Result<[RecentSearch], Error>, Never> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.success(.failure(RealmError.repositoryDeallocated)))
                return
            }

            guard let realm = self.realm else {
                promise(.success(.failure(RealmError.realmInitializationFailed)))
                return
            }

            let results = realm.objects(RecentSearchRealm.self)
                .sorted(byKeyPath: "searchedAt", ascending: false)
                .map { $0.toDomain() }

            promise(.success(.success(Array(results))))
        }
        .eraseToAnyPublisher()
    }

    // 저장
    public func save(keyword: String) -> AnyPublisher<Result<Void, Error>, Never> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.success(.failure(RealmError.repositoryDeallocated)))
                return
            }

            guard let realm = self.realm else {
                promise(.success(.failure(RealmError.realmInitializationFailed)))
                return
            }

            do {
                try realm.write {
                    let objects = realm.objects(RecentSearchRealm.self).filter( "keyword == %@", keyword )
                    realm.delete(objects)
                    let recentSearch = RecentSearchRealm(keyword: keyword, searchedAt: Date())
                    realm.add(recentSearch)
                }
                promise(.success(.success(())))
            } catch {
                promise(.success(.failure(RealmError.writeTransactionFailed)))
            }
        }
        .eraseToAnyPublisher()
    }

    // 삭제
    public func delete(keyword: String) -> AnyPublisher<Result<Void, Error>, Never> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.success(.failure(RealmError.repositoryDeallocated)))
                return
            }

            guard let realm = self.realm else {
                promise(.success(.failure(RealmError.realmInitializationFailed)))
                return
            }

            let objects = realm.objects(RecentSearchRealm.self).filter("keyword == %@", keyword)

            guard !objects.isEmpty else {
                promise(.success(.failure(RealmError.recordNotFound)))
                return
            }

            do {
                try realm.write {
                    realm.delete(objects)
                }
                promise(.success(.success(())))
            } catch {
                promise(.success(.failure(RealmError.writeTransactionFailed)))
            }
        }
        .eraseToAnyPublisher()
    }

    // 전체 삭제
    public func deleteAll() -> AnyPublisher<Result<Void, Error>, Never> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.success(.failure(RealmError.repositoryDeallocated)))
                return
            }

            guard let realm = self.realm else {
                promise(.success(.failure(RealmError.realmInitializationFailed)))
                return
            }

            do {
                try realm.write {
                    let allRecentSearches = realm.objects(RecentSearchRealm.self)
                    realm.delete(allRecentSearches)
                }
                promise(.success(.success(())))
            } catch {
                promise(.success(.failure(RealmError.writeTransactionFailed)))
            }
        }
        .eraseToAnyPublisher()
    }
}
