//
//  MountainRouter.swift
//  Data
//
//  Created by 김영훈 on 10/23/25.
//

import Foundation
import Alamofire

enum MountainRouter: Router {
    
    case getMountainInfo(keyword: String, page: Int)
    
    var baseURL: String {
        return APIInfos.Mountain.baseURL
    }
    
    var apiKey: String {
        return APIInfos.Mountain.key
    }
    
    var method: HTTPMethod {
        switch self {
        case .getMountainInfo:
            return .get
        }
    }
    
    var paths: String? {
        switch self {
        case .getMountainInfo:
            return "mntInfoOpenAPI2"
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .getMountainInfo(let keyword, let page):
            return [
                URLQueryItem(name: "searchWrd", value: keyword),
                URLQueryItem(name: "pageNo", value: String(page)),
                URLQueryItem(name: "numOfRows", value: "20"),
                URLQueryItem(name: "ServiceKey", value: apiKey)
            ]
        }
    }
    
    var errorResponse: APIErrorConvertible.Type {
        return MountainErrorResult.self
    }
    
}
