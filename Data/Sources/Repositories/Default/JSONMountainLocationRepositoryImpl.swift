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
    
    public init() {
        loadJSON()
    }
    
    public func fetchMountainLocations() -> AnyPublisher<[MountainLocation], Error> {
        return Just(mountainLocations.map { $0.toDomain() })
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    private func loadJSON() {
        guard let url = Bundle.module.url(forResource: jsonFileName, withExtension: "json") else {
            print("JSON File Not Found")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            mountainLocations = try decoder.decode([MountainLocationDTO].self, from: data)
        } catch {
            print("Failed to load JSON: \(error)")
        }
    }
}
