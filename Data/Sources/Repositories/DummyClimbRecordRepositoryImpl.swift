//
//  DummyClimbRecordRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 10/1/25.
//

import Foundation
import Combine
import Domain

// TODO: Realm
public final class DummyClimbRecordRepositoryImpl: ClimbRecordRepository {

    public static let shared = DummyClimbRecordRepositoryImpl()

    // Dummy data
    private var dummyClimbRecords = ClimbRecord.dummy

    private init() {}
    
    public func fetch(keyword: String, isOnlyBookmarked: Bool) -> AnyPublisher<[ClimbRecord], any Error> {
        var records = dummyClimbRecords

        if !keyword.isEmpty {
            let ids = Mountain.dummy.filter { $0.name.contains(keyword)}.map { $0.id }
            records = records.filter { ids.contains($0.mountain.id) }
        }

        if isOnlyBookmarked {
            records = records.filter { $0.isBookmarked }
        }
        
        records.sort {
            $0.timeLog.first?.time ?? Date() > $1.timeLog.first?.time ?? Date()
        }

        return Just(records)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    public func save(record: ClimbRecord) -> AnyPublisher<Void, Error> {
        dummyClimbRecords.append(record)
        print("✅ ClimbRecord saved: \(record.mountain.name)")
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public func toggleBookmark(recordID: String) -> AnyPublisher<Void, any Error> {
        
        if let index = dummyClimbRecords.firstIndex(where: { $0.id == recordID
        }) {
            dummyClimbRecords[index].isBookmarked.toggle()
        }
        
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public func update(recordID: String, rating: Int, comment: String) -> AnyPublisher<Void, any Error> {
        
        if let index = dummyClimbRecords.firstIndex(where: { $0.id == recordID
        }) {
            dummyClimbRecords[index].score = rating
            dummyClimbRecords[index].comment = comment
        }
        
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public func delete(recordID: String) -> AnyPublisher<Void, any Error> {
        
        if let index = dummyClimbRecords.firstIndex(where: { $0.id == recordID
        }) {
            dummyClimbRecords.remove(at: index)
        }
        
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
