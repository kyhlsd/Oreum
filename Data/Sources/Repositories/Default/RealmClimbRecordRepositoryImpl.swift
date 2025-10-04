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

    private let realm: Realm

    public init() throws {
        self.realm = try Realm()
        print(realm.configuration.fileURL ?? "realm error")
    }

    public func fetch(keyword: String, isOnlyBookmarked: Bool) -> AnyPublisher<[ClimbRecord], any Error> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.failure(NSError(domain: "DefaultClimbRecordRepositoryImpl", code: -1)))
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

            promise(.success(Array(records)))
        }
        .eraseToAnyPublisher()
    }

    public func save(record: ClimbRecord) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.failure(NSError(domain: "DefaultClimbRecordRepositoryImpl", code: -1)))
                return
            }

            do {
                try realm.write {
                    let realmRecord = ClimbRecordRealm(from: record)
                    self.realm.add(realmRecord)
                }
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    public func toggleBookmark(recordID: String) -> AnyPublisher<Void, any Error> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.failure(NSError(domain: "DefaultClimbRecordRepositoryImpl", code: -1)))
                return
            }

            guard let objectId = try? ObjectId(string: recordID),
                  let record = realm.object(ofType: ClimbRecordRealm.self, forPrimaryKey: objectId) else {
                promise(.failure(NSError(domain: "DefaultClimbRecordRepositoryImpl", code: -2, userInfo: [NSLocalizedDescriptionKey: "Record not found"])))
                return
            }

            do {
                try realm.write {
                    let currentValue = record.value(forKey: "isBookmarked") as! Bool
                    record.setValue(!currentValue, forKey: "isBookmarked")
                }
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    public func update(recordID: String, rating: Int, comment: String) -> AnyPublisher<Void, any Error> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.failure(NSError(domain: "DefaultClimbRecordRepositoryImpl", code: -1)))
                return
            }

            guard let objectId = try? ObjectId(string: recordID),
                  let record = realm.object(ofType: ClimbRecordRealm.self, forPrimaryKey: objectId) else {
                promise(.failure(NSError(domain: "DefaultClimbRecordRepositoryImpl", code: -2, userInfo: [NSLocalizedDescriptionKey: "Record not found"])))
                return
            }

            do {
                try realm.write {
                    record.setValue(rating, forKey: "score")
                    record.setValue(comment, forKey: "comment")
                }
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    public func delete(recordID: String) -> AnyPublisher<Void, any Error> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.failure(NSError(domain: "DefaultClimbRecordRepositoryImpl", code: -1)))
                return
            }

            guard let objectId = try? ObjectId(string: recordID),
                  let record = realm.object(ofType: ClimbRecordRealm.self, forPrimaryKey: objectId) else {
                promise(.failure(NSError(domain: "DefaultClimbRecordRepositoryImpl", code: -2, userInfo: [NSLocalizedDescriptionKey: "Record not found"])))
                return
            }

            do {
                try realm.write {
                    self.realm.delete(record.images)
                    if let mountain = record.mountain {
                        self.realm.delete(mountain)
                    }
                    self.realm.delete(record.timeLog)
                    self.realm.delete(record)
                }
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    public func addImage(recordID: String, imageID: String) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.failure(NSError(domain: "DefaultClimbRecordRepositoryImpl", code: -1)))
                return
            }

            guard let objectId = try? ObjectId(string: recordID),
                  let record = realm.object(ofType: ClimbRecordRealm.self, forPrimaryKey: objectId) else {
                promise(.failure(NSError(domain: "DefaultClimbRecordRepositoryImpl", code: -2, userInfo: [NSLocalizedDescriptionKey: "Record not found"])))
                return
            }

            do {
                try realm.write {
                    let imageRealm = RecordImageRealm(from: imageID)
                    record.images.append(imageRealm)
                }
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    public func removeImage(imageID: String) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.failure(NSError(domain: "DefaultClimbRecordRepositoryImpl", code: -1)))
                return
            }

            guard let imageObjectId = try? ObjectId(string: imageID),
                  let imageRealm = realm.object(ofType: RecordImageRealm.self, forPrimaryKey: imageObjectId) else {
                promise(.failure(NSError(domain: "DefaultClimbRecordRepositoryImpl", code: -2, userInfo: [NSLocalizedDescriptionKey: "Image not found"])))
                return
            }

            do {
                try realm.write {
                    self.realm.delete(imageRealm)
                }
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
