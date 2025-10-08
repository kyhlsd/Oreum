//
//  Router.swift
//  Data
//
//  Created by 김영훈 on 10/6/25.
//

import Foundation
import Alamofire

protocol Router: URLRequestConvertible {
    
    var baseURL: String { get }
    var apiKey: String { get }
    var method: HTTPMethod { get }
    var paths: String? { get }
    var queryItems: [URLQueryItem] { get }
    var errorResponse: APIErrorConvertible.Type { get }
}

extension Router {
    
    func asURLRequest() throws -> URLRequest {
        var url = try baseURL.asURL()
        if let paths {
            url = url.appendingPathComponent(paths)
        }
        url = url.appending(queryItems: queryItems)
        return try URLRequest(url: url, method: method)
    }
    
}
