//
//  JSONMountainInfoRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 10/4/25.
//

import Foundation
import Combine
import Domain

// API 복구 시 API로 대체
public final class JSONMountainInfoRepositoryImpl: MountainInfoRepository {
   
    private let jsonFileName = "MountainInfos"
    private var mountainInfos = [MountainInfoDTO]()
    
    public init() {
        loadJSON()
    }
    
    public func fetchMountains(keyword: String) -> AnyPublisher<[Domain.MountainInfo], Error> {
        guard !keyword.isEmpty else {
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        let filtered = mountainInfos.filter { mountain in
            mountain.MNTN_NM.localizedCaseInsensitiveContains(keyword) ||
            mountain.MNTN_LOCPLC_REGION_NM.localizedCaseInsensitiveContains(keyword)
        }
        
        return Just(filtered.map { $0.toDomain()} )
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
            decoder.dateDecodingStrategy = .iso8601
            mountainInfos = try decoder.decode([MountainInfoDTO].self, from: data)
        } catch {
            print("Failed to load JSON: \(error)")
        }
    }
    
}
