//
//  FetchWeeklyForecastUseCaseTests.swift
//  DomainTests
//
//  Created by 김영훈 on 2025-11-28.
//

import XCTest
import Combine
@testable import Domain
@testable import Data

final class FetchWeeklyForecastUseCaseTests: XCTestCase {

    var sut: FetchWeeklyForecastUseCaseImpl!
    var dummyRepository: DummyForecastRepositoryImpl!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        dummyRepository = DummyForecastRepositoryImpl()
        sut = FetchWeeklyForecastUseCaseImpl(repository: dummyRepository)
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        sut = nil
        dummyRepository = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_execute_WithEmptyForecastItems_ReturnsEmptyArray() {
        // Given
        dummyRepository.mockForecastItems = []
        let expectation = expectation(description: "Empty forecast items")

        // When
        sut.execute(longitude: 126.9780, latitude: 37.5665)
            .sink { result in
                switch result {
                case .success(let forecasts):
                    // Then
                    XCTAssertTrue(forecasts.isEmpty)
                    expectation.fulfill()
                case .failure:
                    XCTFail("빈 예보 항목에서 실패하면 안 됨")
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func test_execute_WithSingleDayForecast_ReturnsProcessedForecast() {
        // Given
        let mockItems = [
            ForecastItem(date: "20251128", time: "0900", category: "TMP", value: "10"),
            ForecastItem(date: "20251128", time: "1200", category: "TMP", value: "15"),
            ForecastItem(date: "20251128", time: "1500", category: "TMP", value: "12"),
            ForecastItem(date: "20251128", time: "0900", category: "POP", value: "30"),
            ForecastItem(date: "20251128", time: "1200", category: "POP", value: "50"),
            ForecastItem(date: "20251128", time: "0900", category: "PTY", value: "0"),
        ]
        dummyRepository.mockForecastItems = mockItems
        let expectation = expectation(description: "Single day forecast")

        // When
        sut.execute(longitude: 126.9780, latitude: 37.5665)
            .sink { result in
                switch result {
                case .success(let forecasts):
                    // Then
                    XCTAssertEqual(forecasts.count, 1)
                    let forecast = forecasts[0]
                    XCTAssertEqual(forecast.minTemp, 10.0)
                    XCTAssertEqual(forecast.maxTemp, 15.0)
                    XCTAssertEqual(forecast.pop, 50) // 최대값
                    XCTAssertEqual(forecast.pty, 0)
                    expectation.fulfill()
                case .failure:
                    XCTFail("단일 날짜 예보에서 실패하면 안 됨")
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func test_execute_WithMultipleDaysForecast_ReturnsGroupedAndSortedForecasts() {
        // Given
        let mockItems = [
            // 11월 28일
            ForecastItem(date: "20251128", time: "0900", category: "TMP", value: "10"),
            ForecastItem(date: "20251128", time: "1200", category: "TMP", value: "15"),
            ForecastItem(date: "20251128", time: "0900", category: "POP", value: "30"),
            ForecastItem(date: "20251128", time: "0900", category: "PTY", value: "0"),
            // 11월 29일
            ForecastItem(date: "20251129", time: "0900", category: "TMP", value: "8"),
            ForecastItem(date: "20251129", time: "1200", category: "TMP", value: "12"),
            ForecastItem(date: "20251129", time: "0900", category: "POP", value: "60"),
            ForecastItem(date: "20251129", time: "0900", category: "PTY", value: "1"),
            // 11월 27일 (이전 날짜)
            ForecastItem(date: "20251127", time: "0900", category: "TMP", value: "5"),
            ForecastItem(date: "20251127", time: "1200", category: "TMP", value: "9"),
            ForecastItem(date: "20251127", time: "0900", category: "POP", value: "20"),
            ForecastItem(date: "20251127", time: "0900", category: "PTY", value: "0"),
        ]
        dummyRepository.mockForecastItems = mockItems
        let expectation = expectation(description: "Multiple days forecast")

        // When
        sut.execute(longitude: 126.9780, latitude: 37.5665)
            .sink { result in
                switch result {
                case .success(let forecasts):
                    // Then
                    XCTAssertEqual(forecasts.count, 3)

                    // 날짜순으로 정렬되어야 함
                    XCTAssertLessThan(forecasts[0].date, forecasts[1].date)
                    XCTAssertLessThan(forecasts[1].date, forecasts[2].date)

                    // 각 날짜의 데이터 확인
                    let forecast27 = forecasts[0]
                    XCTAssertEqual(forecast27.minTemp, 5.0)
                    XCTAssertEqual(forecast27.maxTemp, 9.0)
                    XCTAssertEqual(forecast27.pop, 20)
                    XCTAssertEqual(forecast27.pty, 0)

                    let forecast28 = forecasts[1]
                    XCTAssertEqual(forecast28.minTemp, 10.0)
                    XCTAssertEqual(forecast28.maxTemp, 15.0)
                    XCTAssertEqual(forecast28.pop, 30)
                    XCTAssertEqual(forecast28.pty, 0)

                    let forecast29 = forecasts[2]
                    XCTAssertEqual(forecast29.minTemp, 8.0)
                    XCTAssertEqual(forecast29.maxTemp, 12.0)
                    XCTAssertEqual(forecast29.pop, 60)
                    XCTAssertEqual(forecast29.pty, 1)

                    expectation.fulfill()
                case .failure:
                    XCTFail("다중 날짜 예보에서 실패하면 안 됨")
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func test_execute_WithInvalidDateFormat_SkipsThatDate() {
        // Given
        let mockItems = [
            ForecastItem(date: "20251128", time: "0900", category: "TMP", value: "10"),
            ForecastItem(date: "20251128", time: "1200", category: "TMP", value: "15"),
            ForecastItem(date: "20251128", time: "0900", category: "POP", value: "30"),
            ForecastItem(date: "20251128", time: "0900", category: "PTY", value: "0"),
            // 잘못된 날짜 형식
            ForecastItem(date: "invalid", time: "0900", category: "TMP", value: "20"),
        ]
        dummyRepository.mockForecastItems = mockItems
        let expectation = expectation(description: "Invalid date format")

        // When
        sut.execute(longitude: 126.9780, latitude: 37.5665)
            .sink { result in
                switch result {
                case .success(let forecasts):
                    // Then
                    // 잘못된 날짜는 제외되고 유효한 날짜만 반환됨
                    XCTAssertEqual(forecasts.count, 1)
                    expectation.fulfill()
                case .failure:
                    XCTFail("잘못된 날짜가 있어도 유효한 날짜는 처리되어야 함")
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func test_execute_WithNoTemperatureData_SkipsThatDate() {
        // Given
        let mockItems = [
            // 온도 데이터 없음
            ForecastItem(date: "20251128", time: "0900", category: "POP", value: "30"),
            ForecastItem(date: "20251128", time: "0900", category: "PTY", value: "0"),
        ]
        dummyRepository.mockForecastItems = mockItems
        let expectation = expectation(description: "No temperature data")

        // When
        sut.execute(longitude: 126.9780, latitude: 37.5665)
            .sink { result in
                switch result {
                case .success(let forecasts):
                    // Then
                    // 온도 데이터가 없으면 해당 날짜는 제외됨
                    XCTAssertTrue(forecasts.isEmpty)
                    expectation.fulfill()
                case .failure:
                    XCTFail("온도 데이터가 없어도 에러가 아님")
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func test_execute_ConvertsCoordinatesToGrid() {
        // Given
        dummyRepository.mockForecastItems = []
        let expectation = expectation(description: "Coordinate conversion")

        // 서울시청 좌표
        let longitude = 126.9780
        let latitude = 37.5665

        // When
        sut.execute(longitude: longitude, latitude: latitude)
            .sink { result in
                switch result {
                case .success:
                    // Then
                    // 좌표가 격자 좌표로 변환되어 repository에 전달되었는지 확인
                    XCTAssertNotNil(self.dummyRepository.lastNx)
                    XCTAssertNotNil(self.dummyRepository.lastNy)
                    expectation.fulfill()
                case .failure:
                    XCTFail("좌표 변환에서 실패하면 안 됨")
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func test_execute_WithRepositoryError_ReturnsFailure() {
        // Given
        dummyRepository.shouldReturnError = true
        let expectation = expectation(description: "Repository error")

        // When
        sut.execute(longitude: 126.9780, latitude: 37.5665)
            .sink { result in
                switch result {
                case .success:
                    XCTFail("에러가 발생해야 함")
                case .failure(let error):
                    // Then
                    XCTAssertNotNil(error)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func test_execute_AggregatesMaxPOPAndPTY() {
        // Given
        let mockItems = [
            ForecastItem(date: "20251128", time: "0900", category: "TMP", value: "10"),
            ForecastItem(date: "20251128", time: "0900", category: "POP", value: "30"),
            ForecastItem(date: "20251128", time: "1200", category: "POP", value: "50"),
            ForecastItem(date: "20251128", time: "1500", category: "POP", value: "20"),
            ForecastItem(date: "20251128", time: "0900", category: "PTY", value: "0"),
            ForecastItem(date: "20251128", time: "1200", category: "PTY", value: "1"),
            ForecastItem(date: "20251128", time: "1500", category: "PTY", value: "2"),
        ]
        dummyRepository.mockForecastItems = mockItems
        let expectation = expectation(description: "Max POP and PTY")

        // When
        sut.execute(longitude: 126.9780, latitude: 37.5665)
            .sink { result in
                switch result {
                case .success(let forecasts):
                    // Then
                    XCTAssertEqual(forecasts.count, 1)
                    let forecast = forecasts[0]
                    XCTAssertEqual(forecast.pop, 50, "최대 강수확률 50%")
                    XCTAssertEqual(forecast.pty, 2, "최대 강수형태 2")
                    expectation.fulfill()
                case .failure:
                    XCTFail("집계에서 실패하면 안 됨")
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }
}
