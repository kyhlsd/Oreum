//
//  ClimbRecordRepository.swift
//  Domain
//
//  Created by 김영훈 on 9/27/25.
//

import Combine

public protocol ClimbRecordRepository {
    func fetchClimbRecords() -> AnyPublisher<[ClimbRecord], Error>
    func search(keyword: String) -> AnyPublisher<[ClimbRecord], Error>
}
// TODO: Realm
public final class ClimbRecordRepositoryImpl: ClimbRecordRepository {
    
    public init() {}
    
    public func fetchClimbRecords() -> AnyPublisher<[ClimbRecord], any Error> {
        let records = ClimbRecord.dummy
        return Just(records)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public func search(keyword: String) -> AnyPublisher<[ClimbRecord], any Error> {
        let records = ClimbRecord.dummy
        if keyword.isEmpty {
            return Just(records)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        let id = Mountain.dummy.filter { $0.name.contains(keyword)}.first?.id
        let results = records.filter { $0.mountainId == id}
        return Just(results)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
