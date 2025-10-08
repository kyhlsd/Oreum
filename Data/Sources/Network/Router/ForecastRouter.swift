//
//  ForecastRouter.swift
//  Data
//
//  Created by 김영훈 on 10/7/25.
//

import Foundation
import Alamofire

enum ForecastRouter: Router {
    
    case getShortTermForecast(nx: Int, ny: Int)
    
    var baseURL: String {
        return APIInfos.Forecast.baseURL
    }
    
    var apiKey: String {
        return APIInfos.Forecast.key
    }
    
    var method: HTTPMethod {
        switch self {
        case .getShortTermForecast:
            return .get
        }
    }
    
    var version: String {
        switch self {
        case .getShortTermForecast:
            return "2"
        }
    }
    
    var paths: String? {
        switch self {
        case .getShortTermForecast:
            return "/typ0\(version)/openApi/VilageFcstInfoService_\(version).0/getVilageFcst"
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .getShortTermForecast(let nx, let ny):
            let (baseDate, baseTime) = lastestBaseDateTime
            return [
                URLQueryItem(name: "pageNo", value: "1"),
                URLQueryItem(name: "numOfRows", value: "1000"),
                URLQueryItem(name: "dataType", value: "JSON"),
                URLQueryItem(name: "base_date", value: baseDate),
                URLQueryItem(name: "base_time", value: baseTime),
                URLQueryItem(name: "nx", value: String(nx)),
                URLQueryItem(name: "ny", value: String(ny)),
                URLQueryItem(name: "authKey", value: apiKey)
            ]
        }
    }
    
    var errorResponse: APIErrorConvertible.Type {
        return ForecastErrorResult.self
    }
    
}

extension ForecastRouter {
    
    static let formatter = {
       let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter
    }()
    
    var lastestBaseDateTime: (baseDate: String, baseTime: String) {
        let calendar = Calendar(identifier: .gregorian)
        let hour = calendar.component(.hour, from: Date())
        
        let baseDate: Date
        if hour < 2 {
            baseDate = calendar.date(byAdding: .day, value: -1, to: Date())!
        } else {
            baseDate = Date()
        }
        
        let baseHours = [2, 5, 8, 11, 14, 17, 20, 23]
        let latestHour = baseHours.filter { $0 <= hour }.max() ?? 23
        
        let baseDateString = Self.formatter.string(from: baseDate)
        let baseTimeString = String(format: "%02d00", latestHour)
        
        return (baseDateString, baseTimeString)
    }
}
