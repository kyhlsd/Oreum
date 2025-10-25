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

public final class NetworkManager {
    
    public static let shared = NetworkManager()
    private init() {}
    
    private let queue = DispatchQueue.global(qos: .background)
    private let monitor = NWPathMonitor()
    
    private(set) var isConnected = true
    
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
    
    func callRequest<T: Decodable>(url: Router, type: T.Type = T.self) -> AnyPublisher<Result<T, APIError>, Never> {
        guard isConnected else {
            return Just(.failure(.network)).eraseToAnyPublisher()
        }

        return Future<Result<T, APIError>, Never> { promise in
            AF.request(url)
                .validate()
                .responseDecodable(of: type) { response in
                    switch response.result {
                    case .success(let value):
                        promise(.success(.success(value)))
                    case .failure:
                        if let data = response.data, let errorResult = try? JSONDecoder().decode(url.errorResponse, from: data) {
                            promise(.success(.failure(.some(message: errorResult.message))))
                        } else {
                            promise(.success(.failure(.unknown)))
                        }
                    }
                }
        }
        .eraseToAnyPublisher()
    }

    // XML 응답
    func callXMLRequest<T: Decodable & Sendable>(url: Router, type: T.Type = T.self) -> AnyPublisher<Result<T, APIError>, Never> {
        guard isConnected else {
            return Just(.failure(.network)).eraseToAnyPublisher()
        }

        return Future<Result<T, APIError>, Never> { promise in
            AF.request(url)
                .validate()
                .responseData(queue: DispatchQueue.global(qos: .userInitiated)) { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            let decoder = XMLDecoder()
                            let value = try decoder.decode(type, from: data)
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
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

}
