//
//  ClimbRecordRepository.swift
//  Domain
//
//  Created by 김영훈 on 9/27/25.
//

import Combine

public protocol ClimbRecordRepository {
    func fetch(keyword: String, isOnlyBookmarked: Bool) -> AnyPublisher<[ClimbRecord], Error>
    func save(record: ClimbRecord) -> AnyPublisher<ClimbRecord, Error>
    func toggleBookmark(recordID: String) -> AnyPublisher<Void, Error>
    func update(recordID: String, rating: Int, comment: String) -> AnyPublisher<Void, any Error>
    func delete(recordID: String) -> AnyPublisher<Void, any Error>
    func addImage(recordID: String, imageID: String) -> AnyPublisher<Void, Error>
    func removeImage(imageID: String) -> AnyPublisher<Void, Error>
}
