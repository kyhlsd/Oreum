//
//  RecordImageRepository.swift
//  Domain
//
//  Created by 김영훈 on 10/4/25.
//

import Foundation
import Combine

public protocol RecordImageRepository {
    func saveImage(recordID: String, imageData: Data) -> AnyPublisher<String, Error>
    func deleteImage(imageID: String) -> AnyPublisher<Void, Error>
    func fetchImage(imageID: String) -> AnyPublisher<Data, Error>
}
