//
//  DummyRecordImageRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 10/8/25.
//

import Foundation
import Combine
import RealmSwift
import Domain

public final class DummyRecordImageRepositoryImpl: RecordImageRepository {

    public static let shared = DummyRecordImageRepositoryImpl()

    private var imageStorage: [String: Data] = [:]

    private init() {}

    public func saveImage(imageData: Data) -> AnyPublisher<Result<String, Error>, Never> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.success(.failure(FileManagerError.repositoryDeallocated)))
                return
            }

            let imageID = ObjectId.generate().stringValue
            self.imageStorage[imageID] = imageData
            promise(.success(.success(imageID)))
        }
        .delay(for: .seconds(0.1), scheduler: RunLoop.main)
        .eraseToAnyPublisher()
    }

    public func deleteImage(imageID: String) -> AnyPublisher<Result<Void, Error>, Never> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.success(.failure(FileManagerError.repositoryDeallocated)))
                return
            }

            self.imageStorage.removeValue(forKey: imageID)
            promise(.success(.success(())))
        }
        .delay(for: .seconds(0.1), scheduler: RunLoop.main)
        .eraseToAnyPublisher()
    }

    public func fetchImage(imageID: String) -> AnyPublisher<Result<Data, Error>, Never> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.success(.failure(FileManagerError.repositoryDeallocated)))
                return
            }

            if let imageData = self.imageStorage[imageID] {
                promise(.success(.success(imageData)))
            } else {
                promise(.success(.failure(FileManagerError.imageFileNotFound)))
            }
        }
        .delay(for: .seconds(0.1), scheduler: RunLoop.main)
        .eraseToAnyPublisher()
    }
}
