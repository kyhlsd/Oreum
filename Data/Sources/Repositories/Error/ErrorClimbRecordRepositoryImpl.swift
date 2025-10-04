//
//  ErrorClimbRecordRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 10/4/25.
//

import Foundation
import Combine
import Domain

// Realm 생성 실패 시 반환
public final class ErrorClimbRecordRepositoryImpl: ClimbRecordRepository {

    private let error = NSError(domain: "ErrorClimbRecordRepositoryImpl", code: -1, userInfo: [NSLocalizedDescriptionKey: "Repository is unavailable"])

    public init() {}

    public func fetch(keyword: String, isOnlyBookmarked: Bool) -> AnyPublisher<[ClimbRecord], any Error> {
        return Fail(error: error)
            .eraseToAnyPublisher()
    }

    public func save(record: ClimbRecord) -> AnyPublisher<Void, Error> {
        return Fail(error: error)
            .eraseToAnyPublisher()
    }

    public func toggleBookmark(recordID: String) -> AnyPublisher<Void, any Error> {
        return Fail(error: error)
            .eraseToAnyPublisher()
    }

    public func update(recordID: String, rating: Int, comment: String) -> AnyPublisher<Void, any Error> {
        return Fail(error: error)
            .eraseToAnyPublisher()
    }

    public func delete(recordID: String) -> AnyPublisher<Void, any Error> {
        return Fail(error: error)
            .eraseToAnyPublisher()
    }

    public func addImage(recordID: String, imageID: String) -> AnyPublisher<Void, Error> {
        return Fail(error: error)
            .eraseToAnyPublisher()
    }

    public func removeImage(imageID: String) -> AnyPublisher<Void, Error> {
        return Fail(error: error)
            .eraseToAnyPublisher()
    }
}
