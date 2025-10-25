//
//  NetworkManager.swift
//  Data
//
//  Created by 김영훈 on 10/6/25.
//

import Foundation
import Combine
import Network
import Alamofire
import XMLCoder

public final class NetworkManager: Sendable {

    public static let shared = NetworkManager()
    private init() {}

    private let queue = DispatchQueue.global(qos: .background)
    private let monitor = NWPathMonitor()
    private let cache = NetworkCache.shared

    nonisolated(unsafe) private(set) var isConnected = true
    
    public func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            
            if path.status == .satisfied {
                isConnected = true
            } else {
                isConnected = false
            }
        }
        monitor.start(queue: queue)
    }
    
    public func stopMonitoring() {
        monitor.cancel()
    }
    
    // JSON 응답
    func callRequest<T: Decodable & Sendable>(url: Router, type: T.Type = T.self) -> AnyPublisher<Result<T, APIError>, Never> {
        return Future<Result<T, APIError>, Never> { [weak self] promise in
            guard let self else {
                promise(.success(.failure(.unknown)))
                return
            }

            // 캐시 키 생성
            guard let urlRequest = try? url.asURLRequest(),
                  let cacheKey = urlRequest.url?.absoluteString else {
                promise(.success(.failure(.unknown)))
                return
            }

            Task {
                // L1 & L2: 캐시 확인 (NSCache → FileManager)
                if let cachedData = await self.cache.getData(for: cacheKey) {
                    // 캐시된 데이터로 디코딩
                    do {
                        let decoder = JSONDecoder()
                        let value = try decoder.decode(type, from: cachedData)
                        promise(.success(.success(value)))
                        return
                    } catch {
                        // 캐시 데이터가 손상되었으면 제거하고 네트워크 요청
                        await self.cache.removeData(for: cacheKey)
                    }
                }

                // 네트워크 연결 확인
                guard self.isConnected else {
                    promise(.success(.failure(.network)))
                    return
                }

                // 네트워크 요청
                AF.request(url)
                    .validate()
                    .responseData { response in
                        Task {
                            switch response.result {
                            case .success(let data):
                                do {
                                    let decoder = JSONDecoder()
                                    let value = try decoder.decode(type, from: data)

                                    // 성공한 응답 캐싱
                                    await self.cache.setData(data, for: cacheKey)

                                    promise(.success(.success(value)))
                                } catch {
                                    promise(.success(.failure(.unknown)))
                                }
                            case .failure:
                                if let data = response.data, let errorResult = try? JSONDecoder().decode(url.errorResponse, from: data) {
                                    promise(.success(.failure(.some(message: errorResult.message))))
                                } else {
                                    promise(.success(.failure(.unknown)))
                                }
                            }
                        }
                    }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    // XML 응답
    func callXMLRequest<T: Decodable & Sendable>(url: Router, type: T.Type = T.self) -> AnyPublisher<Result<T, APIError>, Never> {
        return Future<Result<T, APIError>, Never> { [weak self] promise in
            guard let self else {
                promise(.success(.failure(.unknown)))
                return
            }

            // 캐시 키 생성
            guard let urlRequest = try? url.asURLRequest(),
                  let cacheKey = urlRequest.url?.absoluteString else {
                promise(.success(.failure(.unknown)))
                return
            }

            Task {
                // L1 & L2: 캐시 확인 (NSCache → FileManager)
                if let cachedData = await self.cache.getData(for: cacheKey) {
                    // 캐시된 데이터로 디코딩
                    do {
                        let decoder = XMLDecoder()
                        let value = try decoder.decode(type, from: cachedData)
                        promise(.success(.success(value)))
                        return
                    } catch {
                        // 캐시 데이터가 손상되었으면 제거하고 네트워크 요청
                        await self.cache.removeData(for: cacheKey)
                    }
                }

                // 네트워크 연결 확인
                guard self.isConnected else {
                    promise(.success(.failure(.network)))
                    return
                }

                // 네트워크 요청
                AF.request(url)
                    .validate()
                    .responseData(queue: DispatchQueue.global(qos: .userInitiated)) { response in
                        Task {
                            switch response.result {
                            case .success(let data):
                                do {
                                    let decoder = XMLDecoder()
                                    let value = try decoder.decode(type, from: data)

                                    // 성공한 응답 캐싱
                                    await self.cache.setData(data, for: cacheKey)

                                    promise(.success(.success(value)))
                                } catch {
                                    promise(.success(.failure(.unknown)))
                                }
                            case .failure:
                                if let data = response.data {
                                    do {
                                        let decoder = XMLDecoder()
                                        let errorResult = try decoder.decode(url.errorResponse, from: data)
                                        promise(.success(.failure(.some(message: errorResult.message))))
                                    } catch {
                                        promise(.success(.failure(.unknown)))
                                    }
                                } else {
                                    promise(.success(.failure(.unknown)))
                                }
                            }
                        }
                    }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    // MARK: - Cache Management

    // 특정 URL의 캐시 삭제
    public func clearCache(for url: Router) async {
        guard let urlRequest = try? url.asURLRequest(),
              let cacheKey = urlRequest.url?.absoluteString else {
            return
        }
        await cache.removeData(for: cacheKey)
    }

    // 모든 캐시 삭제
    public func clearAllCache() async {
        await cache.clearAll()
    }

    // 만료된 캐시 정리
    public func cleanExpiredCache() async {
        await cache.cleanExpiredCache()
    }

}
