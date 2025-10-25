//
//  RealmClimbRecordRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 10/4/25.
//

import Foundation
import Combine
import RealmSwift
import Domain

public final class RealmClimbRecordRepositoryImpl: ClimbRecordRepository {

    private let realm: Realm?

    public init() {
        self.realm = RealmHelper.shared
    }

    // 기록 가져오기
    public func fetch(keyword: String, isOnlyBookmarked: Bool) -> AnyPublisher<Result<[ClimbRecord], Error>, Never> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.success(.failure(RealmError.repositoryDeallocated)))
                return
            }

            guard let realm = self.realm else {
                promise(.success(.failure(RealmError.realmInitializationFailed)))
                return
            }

            var query = realm.objects(ClimbRecordRealm.self)

            if !keyword.isEmpty {
                query = query.where { $0.mountain.name.contains(keyword, options: .caseInsensitive)}
            }

            if isOnlyBookmarked {
                query = query.where { $0.isBookmarked }
            }

            query = query.sorted(byKeyPath: "climbDate", ascending: false)

            let records = query.map { $0.toDomain() }

            promise(.success(.success(Array(records))))
        }
        .eraseToAnyPublisher()
    }

    // 저장
    public func save(record: ClimbRecord) -> AnyPublisher<Result<ClimbRecord, Error>, Never> {
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
                let realmRecord = ClimbRecordRealm(from: record)
                try realm.write {
                    // MountainRealm의 중복 저장 방지
                    if let mountain = realmRecord.mountain {
                        if let existingMountain = realm.object(ofType: MountainRealm.self, forPrimaryKey: mountain.id) {
                            realmRecord.mountain = existingMountain
                        } else {
                            realm.add(mountain)
                        }
                    }
                    // ClimbRecordRealm 저장
                    realm.add(realmRecord)
                }
                let savedRecord = realmRecord.toDomain()
                promise(.success(.success(savedRecord)))
            } catch {
                promise(.success(.failure(RealmError.writeTransactionFailed)))
            }
        }
        .eraseToAnyPublisher()
    }

    // 북마크 토글
    public func toggleBookmark(recordID: String) -> AnyPublisher<Result<Void, Error>, Never> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.success(.failure(RealmError.repositoryDeallocated)))
                return
            }

            guard let realm = self.realm else {
                promise(.success(.failure(RealmError.realmInitializationFailed)))
                return
            }

            guard let objectId = try? ObjectId(string: recordID) else {
                promise(.success(.failure(RealmError.invalidObjectID)))
                return
            }

            guard let record = realm.object(ofType: ClimbRecordRealm.self, forPrimaryKey: objectId) else {
                promise(.success(.failure(RealmError.recordNotFound)))
                return
            }

            do {
                try realm.write {
                    let currentValue = record.value(forKey: "isBookmarked") as! Bool
                    record.setValue(!currentValue, forKey: "isBookmarked")
                }
                promise(.success(.success(())))
            } catch {
                promise(.success(.failure(RealmError.writeTransactionFailed)))
            }
        }
        .eraseToAnyPublisher()
    }

    // 기록 수정
    public func update(recordID: String, rating: Int, comment: String) -> AnyPublisher<Result<Void, Error>, Never> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.success(.failure(RealmError.repositoryDeallocated)))
                return
            }

            guard let realm = self.realm else {
                promise(.success(.failure(RealmError.realmInitializationFailed)))
                return
            }

            guard let objectId = try? ObjectId(string: recordID) else {
                promise(.success(.failure(RealmError.invalidObjectID)))
                return
            }

            guard let record = realm.object(ofType: ClimbRecordRealm.self, forPrimaryKey: objectId) else {
                promise(.success(.failure(RealmError.recordNotFound)))
                return
            }

            do {
                try realm.write {
                    record.setValue(rating, forKey: "score")
                    record.setValue(comment, forKey: "comment")
                }
                promise(.success(.success(())))
            } catch {
                promise(.success(.failure(RealmError.writeTransactionFailed)))
            }
        }
        .eraseToAnyPublisher()
    }

    // 삭제
    public func delete(recordID: String) -> AnyPublisher<Result<Void, Error>, Never> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.success(.failure(RealmError.repositoryDeallocated)))
                return
            }

            guard let realm = self.realm else {
                promise(.success(.failure(RealmError.realmInitializationFailed)))
                return
            }

            guard let objectId = try? ObjectId(string: recordID) else {
                promise(.success(.failure(RealmError.invalidObjectID)))
                return
            }

            guard let record = realm.object(ofType: ClimbRecordRealm.self, forPrimaryKey: objectId) else {
                promise(.success(.failure(RealmError.recordNotFound)))
                return
            }

            do {
                try realm.write {
                    realm.delete(record.images)
                    if let mountain = record.mountain {
                        realm.delete(mountain)
                    }
                    realm.delete(record.timeLog)
                    realm.delete(record)
                }
                promise(.success(.success(())))
            } catch {
                promise(.success(.failure(RealmError.writeTransactionFailed)))
            }
        }
        .eraseToAnyPublisher()
    }

    // 이미지 추가
    public func addImage(recordID: String, imageID: String) -> AnyPublisher<Result<Void, Error>, Never> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.success(.failure(RealmError.repositoryDeallocated)))
                return
            }

            guard let realm = self.realm else {
                promise(.success(.failure(RealmError.realmInitializationFailed)))
                return
            }

            guard let objectId = try? ObjectId(string: recordID) else {
                promise(.success(.failure(RealmError.invalidObjectID)))
                return
            }

            guard let record = realm.object(ofType: ClimbRecordRealm.self, forPrimaryKey: objectId) else {
                promise(.success(.failure(RealmError.recordNotFound)))
                return
            }

            do {
                try realm.write {
                    let imageRealm = RecordImageRealm(from: imageID)
                    record.images.append(imageRealm)
                }
                promise(.success(.success(())))
            } catch {
                promise(.success(.failure(RealmError.writeTransactionFailed)))
            }
        }
        .eraseToAnyPublisher()
    }

    // 이미지 제거
    public func removeImage(imageID: String) -> AnyPublisher<Result<Void, Error>, Never> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.success(.failure(RealmError.repositoryDeallocated)))
                return
            }

            guard let realm = self.realm else {
                promise(.success(.failure(RealmError.realmInitializationFailed)))
                return
            }

            guard let imageObjectId = try? ObjectId(string: imageID) else {
                promise(.success(.failure(RealmError.invalidObjectID)))
                return
            }

            guard let imageRealm = realm.object(ofType: RecordImageRealm.self, forPrimaryKey: imageObjectId) else {
                promise(.success(.failure(RealmError.imageNotFound)))
                return
            }

            do {
                try realm.write {
                    realm.delete(imageRealm)
                }
                promise(.success(.success(())))
            } catch {
                promise(.success(.failure(RealmError.writeTransactionFailed)))
            }
        }
        .eraseToAnyPublisher()
    }
}
