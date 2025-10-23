//
//  FetchWeeklyForecastUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/7/25.
//

import Foundation
import Combine

public protocol FetchWeeklyForecastUseCase {
    func execute(longitude: Double, latitude: Double) -> AnyPublisher<Result<[DailyForecast], Error>, Never>
}

public final class FetchWeeklyForecastUseCaseImpl: FetchWeeklyForecastUseCase {

    private let repository: ForecastRepository

    public init(repository: ForecastRepository) {
        self.repository = repository
    }

    public func execute(longitude: Double, latitude: Double) -> AnyPublisher<Result<[DailyForecast], any Error>, Never> {
        let grid = convertToGrid(longitude: longitude, latitude: latitude)
        return repository.fetchShortTermForecast(nx: grid.x, ny: grid.y)
            .map { [weak self] result in
                guard let self = self else {
                    return .failure(NSError(domain: "FetchWeeklyForecastUseCaseImpl", code: -1, userInfo: [NSLocalizedDescriptionKey: "UseCase가 이미 해제되었습니다."]))
                }

                switch result {
                case .success(let items):
                    let dailyForecasts = self.processForecastItems(items)
                    return .success(dailyForecasts)
                case .failure(let error):
                    return .failure(error)
                }
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Private Methods

    /// 위경도 좌표를 기상청 격자 좌표로 변환
    private func convertToGrid(longitude: Double, latitude: Double) -> (x: Int, y: Int) {
        let RE: Double = 6371.00877      // 지구 반경(km)
        let GRID: Double = 5.0            // 격자 간격(km)
        let SLAT1: Double = 30.0          // 투영 위도1(degree)
        let SLAT2: Double = 60.0          // 투영 위도2(degree)
        let OLON: Double = 126.0          // 기준점 경도(degree)
        let OLAT: Double = 38.0           // 기준점 위도(degree)
        let XO: Double = 43               // 기준점 X좌표(GRID)
        let YO: Double = 136              // 기준점 Y좌표(GRID)
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

    /// ForecastItem 배열을 DailyForecast 배열로 가공
    private func processForecastItems(_ items: [ForecastItem]) -> [DailyForecast] {
        // 날짜별 그룹핑
        let groupedByDate = Dictionary(grouping: items, by: { $0.date })

        var dailyForecasts: [DailyForecast] = []

        for (dateString, forecasts) in groupedByDate {
            // TMP: 기온
            let temps = forecasts
                .filter { $0.category == "TMP" }
                .compactMap { Double($0.value) }

            // POP: 강수확률
            let pops = forecasts
                .filter { $0.category == "POP" }
                .compactMap { Int($0.value) }

            // PTY: 강수형태
            let ptys = forecasts
                .filter { $0.category == "PTY" }
                .compactMap { Int($0.value) }

            guard !temps.isEmpty else { continue }

            let minTemp = temps.min() ?? 0
            let maxTemp = temps.max() ?? 0
            let pop = pops.max() ?? 0
            let pty = ptys.max() ?? 0

            // 문자열 날짜를 Date로 변환 (yyyyMMdd)
            guard let date = dateFormatter.date(from: dateString) else { continue }

            let daily = DailyForecast(date: date, minTemp: minTemp, maxTemp: maxTemp, pop: pop, pty: pty)
            dailyForecasts.append(daily)
        }

        // 날짜순 정렬
        return dailyForecasts.sorted(by: { $0.date < $1.date })
    }

    /// yyyyMMdd 형식의 날짜 포맷터
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }
}
