//
//  GeocoderRouter.swift
//  Data
//
//  Created by 김영훈 on 10/6/25.
//

import Foundation
import Alamofire

enum GeocoderRouter: Router {
    
    case getCoordinate(address: String)
    
    var baseURL: String {
        switch self {
        case .getCoordinate:
            return APIInfos.Geocoder.baseURL
        }
    }
    
    var apiKey: String {
        switch self {
        case .getCoordinate:
            return APIInfos.Geocoder.key
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getCoordinate:
            return .get
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .getCoordinate(let address):
            return [
                URLQueryItem(name: "service", value: "address"),
                URLQueryItem(name: "request", value: "getcoord"),
                URLQueryItem(name: "version", value: "2.0"),
                URLQueryItem(name: "crs", value: "epsg:4326"),
                URLQueryItem(name: "address", value: address),
                URLQueryItem(name: "refine", value: "true"),
                URLQueryItem(name: "simple", value: "true"),
                URLQueryItem(name: "format", value: "json"),
                URLQueryItem(name: "type", value: "road"),
                URLQueryItem(name: "key", value: apiKey)
            ]
        }
    }
    
    var errorResponse: APIErrorConvertible.Type {
        return GeocodeErrorResponse.self
    }
}
