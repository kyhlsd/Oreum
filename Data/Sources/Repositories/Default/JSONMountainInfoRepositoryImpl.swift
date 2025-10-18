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
    private var loadError: JSONError?
    
    public init() {
        loadJSON()
    }
    
    // 추후 API 연결 시 ID로 검색으로 수정
    // 산 상세 정보 불러오기
    public func fetchMountainInfo(name: String, height: Int) -> AnyPublisher<Result<MountainInfo, Error>, Never> {
        if let loadError {
            return Just(.failure(loadError))
                .eraseToAnyPublisher()
        }
        
        let mountains = mountainInfos
            .filter { $0.name.first == name.first }
            .sorted {
                abs($0.height - height) < abs($1.height - height)
            }

        if let mountainInfo = mountains.first {
            return Just(.success(mountainInfo))
                .eraseToAnyPublisher()
        } else {
            return Just(.failure(JSONError.mountainNotFound))
                .eraseToAnyPublisher()
        }
    }
    
    // 산 검색
    public func fetchMountains(keyword: String) -> AnyPublisher<Result<[MountainInfo], Error>, Never> {
        if let loadError {
            return Just(.failure(loadError))
                .eraseToAnyPublisher()
        }
        
        guard !keyword.isEmpty else {
            return Just(.success([]))
                .eraseToAnyPublisher()
        }

        let filtered = mountainInfos.filter { mountain in
            mountain.name.localizedCaseInsensitiveContains(keyword)
        }

        return Just(.success(filtered))
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
            decoder.dateDecodingStrategy = .iso8601
            mountainInfos = try decoder.decode([MountainInfoDTO].self, from: data)
                .map { $0.toDomain() }
        } catch {
            loadError = JSONError.decodingFailed
        }
    }
    
}
