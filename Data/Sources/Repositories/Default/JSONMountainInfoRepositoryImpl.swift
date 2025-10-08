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
    private var mountainInfos = [MountainInfo]()
    
    public init() {
        loadJSON()
    }
    
    // 추후 API 연결 시 ID로 검색으로 수정
    public func fetchMountainInfo(name: String, height: Int) -> AnyPublisher<MountainInfo, Error> {
        let mountains = mountainInfos
            .filter { $0.name.first == name.first }
            .sorted {
                abs($0.height - height) < abs($1.height - height)
            }
        
        if let mountainInfo = mountains.first {
            return Just(mountainInfo)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: NSError(domain: "JSONMountainInfoRepositoryImpl", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mountain information not found"]))
                .eraseToAnyPublisher()
        }
    }
    
    public func fetchMountains(keyword: String) -> AnyPublisher<[MountainInfo], Error> {
        guard !keyword.isEmpty else {
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        let filtered = mountainInfos.filter { mountain in
            mountain.name.localizedCaseInsensitiveContains(keyword)
        }
        
        return Just(filtered)
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
                .map { $0.toDomain() }
        } catch {
            print("Failed to load JSON: \(error)")
        }
    }
    
}
