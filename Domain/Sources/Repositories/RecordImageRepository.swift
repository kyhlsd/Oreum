//
//  RecordImageRepository.swift
//  Domain
//
//  Created by 김영훈 on 10/4/25.
//

import Foundation
import Combine

public protocol RecordImageRepository {
    func saveImage(imageData: Data) -> AnyPublisher<Result<String, Error>, Never>
    func deleteImage(imageID: String) -> AnyPublisher<Result<Void, Error>, Never>
    func fetchImage(imageID: String) -> AnyPublisher<Result<Data, Error>, Never>
}
