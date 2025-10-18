//
//  ClimbRecordRepository.swift
//  Domain
//
//  Created by 김영훈 on 9/27/25.
//

import Combine

public protocol ClimbRecordRepository {
    func fetch(keyword: String, isOnlyBookmarked: Bool) -> AnyPublisher<Result<[ClimbRecord], Error>, Never>
    func save(record: ClimbRecord) -> AnyPublisher<Result<ClimbRecord, Error>, Never>
    func toggleBookmark(recordID: String) -> AnyPublisher<Result<Void, Error>, Never>
    func update(recordID: String, rating: Int, comment: String) -> AnyPublisher<Result<Void, Error>, Never>
    func delete(recordID: String) -> AnyPublisher<Result<Void, Error>, Never>
    func addImage(recordID: String, imageID: String) -> AnyPublisher<Result<Void, Error>, Never>
    func removeImage(imageID: String) -> AnyPublisher<Result<Void, Error>, Never>
}
