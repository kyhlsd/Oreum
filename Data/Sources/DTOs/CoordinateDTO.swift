//
//  CoordinateDTO.swift
//  Data
//
//  Created by 김영훈 on 10/6/25.
//

import Foundation
import Domain

struct CoordinateDTO: Decodable {
    let response: GeocodeResponse
    
    struct GeocodeResponse: Decodable {
        private let service: Service
        private let status: String
        private let record: Record?
        private let page: Page?
        let result: ResultPoint?
    }
    
}

extension CoordinateDTO {
    func toDomain() -> Coordinate? {
        if let point = response.result?.point,
           let longitude = Double(point.x),
           let latitude = Double(point.y) {
            return Coordinate(longitude: longitude, latitude: latitude)
        } else {
            return nil
        }
    }
}

extension CoordinateDTO {
    
    private struct Service: Decodable {
        private let name: String
        private let version: String
        private let operation: String
        private let time: String
    }
    
    private struct Record: Decodable {
        private let total: String
        private let current: String
    }
    
    private struct Page: Decodable {
        private let total: String
        private let current: String
        private let size: String
    }
    
    struct ResultPoint: Decodable {
        private let crs: String
        let point: Point
        
        struct Point: Decodable {
            let x: String
            let y: String
        }
    }
    
}
