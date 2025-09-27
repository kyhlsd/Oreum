//
//  ClimbRecordRepository.swift
//  Domain
//
//  Created by 김영훈 on 9/27/25.
//

import Combine

public protocol ClimbRecordRepository {
    func fetch(keyword: String, isOnlyBookmarked: Bool) -> AnyPublisher<[ClimbRecord], Error>
    func toggleBookmark(recordID: String) -> AnyPublisher<Void, Error>
}
// TODO: Realm
public final class ClimbRecordRepositoryImpl: ClimbRecordRepository {
    
    public init() {}
    
    public func fetch(keyword: String, isOnlyBookmarked: Bool) -> AnyPublisher<[ClimbRecord], any Error> {
        var records = ClimbRecord.dummy
        
        if !keyword.isEmpty {
            let id = Mountain.dummy.filter { $0.name.contains(keyword)}.first?.id
            records = records.filter { $0.mountainId == id}
        }
        
        if isOnlyBookmarked {
            records = records.filter { $0.isBookmarked }
        }
        
        return Just(records)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public func toggleBookmark(recordID: String) -> AnyPublisher<Void, any Error> {
        
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
