//
//  CoordinateDTO.swift
//  Data
//
//  Created by 김영훈 on 10/6/25.
//

import Foundation
import Domain

struct CoordinateDTO: Decodable, Sendable {
    
    private let response: GeocodeResponse
    
    private struct GeocodeResponse: Decodable {
        let service: Service
        let status: String
        let result: ResultPoint
    }
    
    private struct ResultPoint: Decodable {
        let crs: String
        let point: Point
    }
    
    private struct Point: Decodable {
        let x: String
        let y: String
    }
    
}

extension CoordinateDTO {
    
    func toDomain() -> Coordinate? {
        let point = response.result.point
            
        if let longitude = Double(point.x),
           let latitude = Double(point.y) {
            return Coordinate(longitude: longitude, latitude: latitude)
        } else {
            return nil
        }
    }
    
}

extension CoordinateDTO {
    
    private struct Service: Decodable {
        let name: String
        let version: String
        let operation: String
        let time: String
    }
    
}
