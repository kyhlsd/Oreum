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
    
    // Dummy data
    private var dummyClimbRecords = ClimbRecord.dummy
    
    public init() {}
    
    public func fetch(keyword: String, isOnlyBookmarked: Bool) -> AnyPublisher<[ClimbRecord], any Error> {
        var records = dummyClimbRecords
        
        if !keyword.isEmpty {
            let id = Mountain.dummy.filter { $0.name.contains(keyword)}.first?.id
            records = records.filter { $0.mountain.id == id}
        }
        
        if isOnlyBookmarked {
            records = records.filter { $0.isBookmarked }
        }
        
        return Just(records)
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
