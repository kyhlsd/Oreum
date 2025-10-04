//
//  DefaultRecordImageRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 10/4/25.
//

import Foundation
import Combine
import Domain

public final class DefaultRecordImageRepositoryImpl: RecordImageRepository {

    public init() {}

    public func saveImage(recordID: String, imageData: Data) -> AnyPublisher<String, Error> {
        return Future { promise in
            // TODO: 실제 이미지 저장 로직 구현
            let imageID = UUID().uuidString
            print("✅ Mock: Image saved with ID: \(imageID) for recordID: \(recordID)")
            print("✅ Mock: Image size: \(imageData.count) bytes")
            promise(.success(imageID))
        }
        .eraseToAnyPublisher()
    }

    public func deleteImage(imageID: String) -> AnyPublisher<Void, Error> {
        return Future { promise in
            // TODO: 실제 이미지 삭제 로직 구현
            print("✅ Mock: Image deleted with ID: \(imageID)")
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }

    public func fetchImage(imageID: String) -> AnyPublisher<Data, Error> {
        return Future { promise in
            // TODO: 실제 이미지 로드 로직 구현
            print("✅ Mock: Image fetched with ID: \(imageID)")
            promise(.success(Data()))
        }
        .eraseToAnyPublisher()
    }
}
