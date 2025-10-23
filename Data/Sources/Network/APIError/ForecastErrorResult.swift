//
//  ForecastErrorResult.swift
//  Data
//
//  Created by 김영훈 on 10/7/25.
//

import Foundation

struct ForecastErrorResult: APIErrorConvertible {
    
    private let response: ForecastErrorResponse
    
    private struct ForecastErrorResponse: Decodable {
        let header: Header
    }
    
    private struct Header: Decodable {
        let resultCode: String
        let resultMsg: String
    }
    
    var message: String {
        return response.header.resultMsg
    }
    
}
