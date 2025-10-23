//
//  ShortTermForecastDTO.swift
//  Data
//
//  Created by 김영훈 on 10/6/25.
//

import Foundation
import Domain

struct ShortTermForecastDTO: Decodable {
    
    let response: ForecastResponse
    
    struct ForecastResponse: Decodable {
        private let header: Header
        let body: Body
    }
    
    struct Body: Decodable {
        private let dataType: String
        let items: Items
        private let pageNo: Int
        private let numOfRows: Int
        private let totalCount: Int
    }
    
    struct Items: Decodable {
        let item: [ShortTermForecastItem]
    }
    
    struct ShortTermForecastItem: Decodable {
        let baseDate: String
        let baseTime: String
        let category: String
        let fcstDate: String
        let fcstTime: String
        let fcstValue: String
        let nx: Int
        let ny: Int
    }

}

extension ShortTermForecastDTO {

    private struct Header: Decodable {
        let resultCode: String
        let resultMsg: String
    }

}

extension ShortTermForecastDTO.ShortTermForecastItem {
    func toDomain() -> ForecastItem {
        return ForecastItem(
            date: fcstDate,
            time: fcstTime,
            category: category,
            value: fcstValue
        )
    }
}
