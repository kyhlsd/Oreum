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

    // 이미지 저장 디렉토리를 가져오거나 생성
    private func getImageDirectory() throws -> URL {
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileManagerError.documentDirectoryNotFound
        }

        let imageDirectory = documentDirectory.appendingPathComponent("RecordImages", isDirectory: true)

        if !fileManager.fileExists(atPath: imageDirectory.path) {
            do {
                try fileManager.createDirectory(at: imageDirectory, withIntermediateDirectories: true)
            } catch {
                throw FileManagerError.failedToCreateImageDirectory
            }
        }

        return imageDirectory
    }

    public func saveImage(imageData: Data) -> AnyPublisher<Result<String, Error>, Never> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.success(.failure(FileManagerError.repositoryDeallocated)))
                return
            }

            do {
                let imageDirectory = try self.getImageDirectory()
                let imageID = ObjectId.generate().stringValue
                let fileURL = imageDirectory.appendingPathComponent("\(imageID).jpg")

                try imageData.write(to: fileURL)
                promise(.success(.success(imageID)))
            } catch let error as FileManagerError {
                promise(.success(.failure(error)))
            } catch {
                promise(.success(.failure(FileManagerError.failedToSaveImage)))
            }
        }
        .eraseToAnyPublisher()
    }

    public func deleteImage(imageID: String) -> AnyPublisher<Result<Void, Error>, Never> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.success(.failure(FileManagerError.repositoryDeallocated)))
                return
            }

            do {
                let imageDirectory = try self.getImageDirectory()
                let fileURL = imageDirectory.appendingPathComponent("\(imageID).jpg")

                if fileManager.fileExists(atPath: fileURL.path) {
                    try fileManager.removeItem(at: fileURL)
                }
                promise(.success(.success(())))
            } catch let error as FileManagerError {
                promise(.success(.failure(error)))
            } catch {
                promise(.success(.failure(FileManagerError.failedToDeleteImage)))
            }
        }
        .eraseToAnyPublisher()
    }

    public func fetchImage(imageID: String) -> AnyPublisher<Result<Data, Error>, Never> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.success(.failure(FileManagerError.repositoryDeallocated)))
                return
            }

            do {
                let imageDirectory = try self.getImageDirectory()
                let fileURL = imageDirectory.appendingPathComponent("\(imageID).jpg")

                guard fileManager.fileExists(atPath: fileURL.path) else {
                    promise(.success(.failure(FileManagerError.imageFileNotFound)))
                    return
                }

                let imageData = try Data(contentsOf: fileURL)
                promise(.success(.success(imageData)))
            } catch let error as FileManagerError {
                promise(.success(.failure(error)))
            } catch {
                promise(.success(.failure(FileManagerError.failedToLoadImage)))
            }
        }
        .eraseToAnyPublisher()
    }
}
