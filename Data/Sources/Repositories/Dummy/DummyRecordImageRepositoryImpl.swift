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

    public func saveImage(imageData: Data) -> AnyPublisher<String, Error> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.failure(NSError(domain: "DummyRecordImageRepositoryImpl", code: -1, userInfo: [NSLocalizedDescriptionKey: "Self is nil"])))
                return
            }

            let imageID = ObjectId.generate().stringValue
            self.imageStorage[imageID] = imageData
            promise(.success(imageID))
        }
        .delay(for: .seconds(0.1), scheduler: RunLoop.main)
        .eraseToAnyPublisher()
    }

    public func deleteImage(imageID: String) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.failure(NSError(domain: "DummyRecordImageRepositoryImpl", code: -1, userInfo: [NSLocalizedDescriptionKey: "Self is nil"])))
                return
            }

            self.imageStorage.removeValue(forKey: imageID)
            promise(.success(()))
        }
        .delay(for: .seconds(0.1), scheduler: RunLoop.main)
        .eraseToAnyPublisher()
    }

    public func fetchImage(imageID: String) -> AnyPublisher<Data, Error> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.failure(NSError(domain: "DummyRecordImageRepositoryImpl", code: -1, userInfo: [NSLocalizedDescriptionKey: "Self is nil"])))
                return
            }

            if let imageData = self.imageStorage[imageID] {
                promise(.success(imageData))
            } else {
                promise(.failure(NSError(domain: "DummyRecordImageRepositoryImpl", code: -2, userInfo: [NSLocalizedDescriptionKey: "Image not found"])))
            }
        }
        .delay(for: .seconds(0.1), scheduler: RunLoop.main)
        .eraseToAnyPublisher()
    }
}
