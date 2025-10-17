//
//  DefaultForecastRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 10/7/25.
//

import Foundation
import Combine
import Domain

public final class DefaultForecastRepositoryImpl: ForecastRepository {
    
    public init() {}
    
    // 단기예보
    public func fetchShortTermForecast(longitude: Double, latitude: Double) -> AnyPublisher<Result<[DailyForecast], Error>, Never> {
        let grid = getGrid(longitude: longitude, latitude: latitude)
        return NetworkManager.shared
            .callRequest(url: ForecastRouter.getShortTermForecast(nx: grid.x, ny: grid.y), type: ShortTermForecastDTO.self)
            .map { [weak self] result in
                guard let self else {
                    return .failure(APIError.unknown)
                }
                
                switch result {
                case .success(let dto):
                    return .success(getShortTermForecasts(from: dto))
                case .failure(let apiError):
                    return .failure(apiError)
                }
            }
            .eraseToAnyPublisher()
    }
    
}

extension DefaultForecastRepositoryImpl {
    
    // 기상청 api에서 요구하는 grid로 변환
    func getGrid(longitude: Double, latitude: Double) -> (x: Int, y: Int) {
        let RE: Double = 6371.00877
        let GRID: Double = 5.0
        let SLAT1: Double = 30.0
        let SLAT2: Double = 60.0
        let OLON: Double = 126.0
        let OLAT: Double = 38.0
        let XO: Double = 43
        let YO: Double = 136
        let DEGRAD = Double.pi / 180.0
        
        let re = RE / GRID
        let slat1 = SLAT1 * DEGRAD
        let slat2 = SLAT2 * DEGRAD
        let olon = OLON * DEGRAD
        let olat = OLAT * DEGRAD
        
        var sn = tan(.pi * 0.25 + slat2 * 0.5) / tan(.pi * 0.25 + slat1 * 0.5)
        sn = log(cos(slat1) / cos(slat2)) / log(sn)
        var sf = tan(.pi * 0.25 + slat1 * 0.5)
        sf = pow(sf, sn) * cos(slat1) / sn
        var ro = tan(.pi * 0.25 + olat * 0.5)
        ro = re * sf / pow(ro, sn)
        
        var ra = tan(.pi * 0.25 + latitude * DEGRAD * 0.5)
        ra = re * sf / pow(ra, sn)
        var theta = longitude * DEGRAD - olon
        if theta > .pi { theta -= 2.0 * .pi }
        if theta < -.pi { theta += 2.0 * .pi }
        theta *= sn
        
        let x = Int(floor(ra * sin(theta) + XO + 0.5))
        let y = Int(floor(ro - ra * cos(theta) + YO + 0.5))
        return (x, y)
    }
    
    func getShortTermForecasts(from dto: ShortTermForecastDTO) -> [DailyForecast] {
        let items = dto.response.body.items.item
        
        // 날짜별 그룹핑
        let groupedByDate = Dictionary(grouping: items, by: { $0.fcstDate })
        
        var dailyForecasts: [DailyForecast] = []
        
        for (dateString, forecasts) in groupedByDate {
            // TMP: 기온
            let temps = forecasts
                .filter { $0.category == "TMP" }
                .compactMap { Double($0.fcstValue) }
            
            // POP: 강수확률
            let pops = forecasts
                .filter { $0.category == "POP" }
                .compactMap { Int($0.fcstValue) }
            
            // PTY: 강수형태
            let ptys = forecasts
                .filter { $0.category == "PTY" }
                .compactMap { Int($0.fcstValue) }
            
            guard !temps.isEmpty else { continue }
            
            let minTemp = temps.min() ?? 0
            let maxTemp = temps.max() ?? 0
            let pop = pops.max() ?? 0
            let pty = ptys.max() ?? 0
            
            // 문자열 날짜를 Date로 변환
            guard let date = ForecastRouter.formatter.date(from: dateString) else { continue }
            
            let daily = DailyForecast(date: date, minTemp: minTemp, maxTemp: maxTemp, pop: pop, pty: pty)
            dailyForecasts.append(daily)
        }
        
        // 날짜순 정렬
        return dailyForecasts.sorted(by: { $0.date < $1.date })
    }

}
