//
//  JSONMountainLocationRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 10/4/25.
//

import Foundation
import Combine
import Domain

public final class JSONMountainLocationRepositoryImpl: MountainLocationRepository {
    
    private let jsonFileName = "FamousMountainLocations"
    private var mountainLocations = [MountainLocationDTO]()
    private var loadError: JSONError?

    public init() {
        loadJSON()
    }
    
    // 산 위경도 불러오기
    public func fetchMountainLocations() -> AnyPublisher<Result<[MountainLocation], Error>, Never> {
        if let loadError {
            return Just(.failure(loadError))
                .eraseToAnyPublisher()
        }

        return Just(.success(mountainLocations.map { $0.toDomain() }))
            .eraseToAnyPublisher()
    }
    
    private func loadJSON() {
        guard let url = Bundle.module.url(forResource: jsonFileName, withExtension: "json") else {
            loadError = JSONError.fileNotFound
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            mountainLocations = try decoder.decode([MountainLocationDTO].self, from: data)
        } catch {
            loadError = JSONError.decodingFailed
        }
    }
}
