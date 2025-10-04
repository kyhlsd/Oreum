//
//  FileManagerRecordImageRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 10/4/25.
//

import Foundation
import Combine
import RealmSwift
import Domain

public final class FileManagerRecordImageRepositoryImpl: RecordImageRepository {

    private let fileManager = FileManager.default

    public init() {}

    private func getImageDirectory() -> URL? {
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let imageDirectory = documentDirectory.appendingPathComponent("RecordImages", isDirectory: true)

        if !fileManager.fileExists(atPath: imageDirectory.path) {
            try? fileManager.createDirectory(at: imageDirectory, withIntermediateDirectories: true)
        }

        return imageDirectory
    }

    public func saveImage(imageData: Data) -> AnyPublisher<String, Error> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.failure(NSError(domain: "DefaultRecordImageRepositoryImpl", code: -1, userInfo: [NSLocalizedDescriptionKey: "Self is nil"])))
                return
            }

            guard let imageDirectory = getImageDirectory() else {
                promise(.failure(NSError(domain: "DefaultRecordImageRepositoryImpl", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to get image directory"])))
                return
            }

            let imageID = ObjectId.generate().stringValue
            let fileURL = imageDirectory.appendingPathComponent("\(imageID).jpg")

            do {
                try imageData.write(to: fileURL)
                promise(.success(imageID))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    public func deleteImage(imageID: String) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.failure(NSError(domain: "DefaultRecordImageRepositoryImpl", code: -1, userInfo: [NSLocalizedDescriptionKey: "Self is nil"])))
                return
            }

            guard let imageDirectory = getImageDirectory() else {
                promise(.failure(NSError(domain: "DefaultRecordImageRepositoryImpl", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to get image directory"])))
                return
            }

            let fileURL = imageDirectory.appendingPathComponent("\(imageID).jpg")

            do {
                if fileManager.fileExists(atPath: fileURL.path) {
                    try fileManager.removeItem(at: fileURL)
                } else {
                }
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    public func fetchImage(imageID: String) -> AnyPublisher<Data, Error> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.failure(NSError(domain: "DefaultRecordImageRepositoryImpl", code: -1, userInfo: [NSLocalizedDescriptionKey: "Self is nil"])))
                return
            }

            guard let imageDirectory = getImageDirectory() else {
                promise(.failure(NSError(domain: "DefaultRecordImageRepositoryImpl", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to get image directory"])))
                return
            }

            let fileURL = imageDirectory.appendingPathComponent("\(imageID).jpg")

            do {
                let imageData = try Data(contentsOf: fileURL)
                promise(.success(imageData))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
