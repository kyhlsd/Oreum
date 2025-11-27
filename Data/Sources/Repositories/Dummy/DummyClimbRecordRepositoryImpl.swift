//
//  DummyClimbRecordRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 10/1/25.
//

import Foundation
import Combine
import Domain

public final class DummyClimbRecordRepositoryImpl: ClimbRecordRepository {

    public static let shared = DummyClimbRecordRepositoryImpl()

    // Dummy data
    private var dummyClimbRecords = ClimbRecord.dummy

    // Test properties
    var mockRecords: [ClimbRecord] = []
    var shouldReturnError = false

    init() {}
    
    public func fetch(keyword: String, isOnlyBookmarked: Bool) -> AnyPublisher<Result<[ClimbRecord], Error>, Never> {
        if shouldReturnError {
            return Just(.failure(NSError(domain: "Test", code: -1, userInfo: nil)))
                .eraseToAnyPublisher()
        }

        // Use mockRecords if available, otherwise use dummy data
        var records = mockRecords.isEmpty ? dummyClimbRecords : mockRecords

        if !keyword.isEmpty {
            let ids = Mountain.dummy.filter { $0.name.contains(keyword)}.map { $0.id }
            records = records.filter { ids.contains($0.mountain.id) }
        }

        if isOnlyBookmarked {
            records = records.filter { $0.isBookmarked }
        }

        records.sort {
            $0.climbDate > $1.climbDate
        }

        return Just(.success(records))
            .eraseToAnyPublisher()
    }

    public func save(record: ClimbRecord) -> AnyPublisher<Result<ClimbRecord, Error>, Never> {
        dummyClimbRecords.append(record)
        return Just(.success(record))
            .eraseToAnyPublisher()
    }
    
    public func toggleBookmark(recordID: String) -> AnyPublisher<Result<Void, Error>, Never> {

        if let index = dummyClimbRecords.firstIndex(where: { $0.id == recordID
        }) {
            dummyClimbRecords[index].isBookmarked.toggle()
        }

        return Just(.success(()))
            .eraseToAnyPublisher()
    }
    
    public func update(recordID: String, rating: Int, comment: String) -> AnyPublisher<Result<Void, Error>, Never> {

        if let index = dummyClimbRecords.firstIndex(where: { $0.id == recordID
        }) {
            dummyClimbRecords[index].score = rating
            dummyClimbRecords[index].comment = comment
        }

        return Just(.success(()))
            .eraseToAnyPublisher()
    }
    
    public func delete(recordID: String) -> AnyPublisher<Result<Void, Error>, Never> {

        if let index = dummyClimbRecords.firstIndex(where: { $0.id == recordID
        }) {
            dummyClimbRecords.remove(at: index)
        }

        return Just(.success(()))
            .eraseToAnyPublisher()
    }

    public func addImage(recordID: String, imageID: String) -> AnyPublisher<Result<Void, Error>, Never> {
        if let index = dummyClimbRecords.firstIndex(where: { $0.id == recordID }) {
            dummyClimbRecords[index].images.append(imageID)
        }

        return Just(.success(()))
            .eraseToAnyPublisher()
    }

    public func removeImage(imageID: String) -> AnyPublisher<Result<Void, Error>, Never> {
        for recordIndex in dummyClimbRecords.indices {
            if let imageIndex = dummyClimbRecords[recordIndex].images.firstIndex(of: imageID) {
                dummyClimbRecords[recordIndex].images.remove(at: imageIndex)
                break
            }
        }

        return Just(.success(()))
            .eraseToAnyPublisher()
    }
}
