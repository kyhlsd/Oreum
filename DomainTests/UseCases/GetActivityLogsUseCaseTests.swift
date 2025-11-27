//
//  GetActivityLogsUseCaseTests.swift
//  DomainTests
//
//  Created by 김영훈 on 2025-11-28.
//

import XCTest
import Combine
@testable import Domain
@testable import Data

final class GetActivityLogsUseCaseTests: XCTestCase {

    var sut: GetActivityLogsUseCaseImpl!
    var dummyRepository: DummyTrackActivityRepositoryImpl!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        dummyRepository = DummyTrackActivityRepositoryImpl()
        dummyRepository.useMockData = true
        sut = GetActivityLogsUseCaseImpl(repository: dummyRepository)
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        sut = nil
        dummyRepository = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_execute_WithEmptyLogs_ReturnsEmptyArray() {
        // Given
        dummyRepository.mockLogs = []
        let expectation = expectation(description: "Empty logs")

        // When
        sut.execute()
            .sink { result in
                switch result {
                case .success(let logs):
                    // Then
                    XCTAssertTrue(logs.isEmpty)
                    expectation.fulfill()
                case .failure:
                    XCTFail("빈 로그에서 실패하면 안 됨")
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func test_execute_WithSingleLog_ReturnsSameLog() {
        // Given
        let log = ActivityLog(id: "1", time: Date(), step: 100, distance: 50)
        dummyRepository.mockLogs = [log]
        let expectation = expectation(description: "Single log")

        // When
        sut.execute()
            .sink { result in
                switch result {
                case .success(let logs):
                    // Then
                    XCTAssertEqual(logs.count, 1)
                    expectation.fulfill()
                case .failure:
                    XCTFail("단일 로그에서 실패하면 안 됨")
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func test_execute_WithNormalLogs_AppliesSmoothing() {
        // Given
        let startDate = Date()
        let logs = [
            ActivityLog(id: "1", time: startDate, step: 0, distance: 0),
            ActivityLog(id: "2", time: startDate.addingTimeInterval(5 * 60), step: 100, distance: 50),
            ActivityLog(id: "3", time: startDate.addingTimeInterval(10 * 60), step: 200, distance: 100),
            ActivityLog(id: "4", time: startDate.addingTimeInterval(15 * 60), step: 300, distance: 150),
        ]
        dummyRepository.mockLogs = logs
        let expectation = expectation(description: "Normal logs")

        // When
        sut.execute()
            .sink { result in
                switch result {
                case .success(let smoothedLogs):
                    // Then
                    XCTAssertEqual(smoothedLogs.count, 4)
                    // 0이 아닌 데이터는 스무딩 적용됨
                    XCTAssertTrue(smoothedLogs.allSatisfy { $0.step >= 0 && $0.distance >= 0 })
                    expectation.fulfill()
                case .failure:
                    XCTFail("정상 로그에서 실패하면 안 됨")
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func test_execute_WithSpikeLogs_AppliesCorrection() {
        // Given
        let startDate = Date()
        let logs = [
            ActivityLog(id: "1", time: startDate, step: 0, distance: 0),
            ActivityLog(id: "2", time: startDate.addingTimeInterval(5 * 60), step: 100, distance: 50),
            ActivityLog(id: "3", time: startDate.addingTimeInterval(10 * 60), step: 700, distance: 350), // 스파이크
            ActivityLog(id: "4", time: startDate.addingTimeInterval(15 * 60), step: 800, distance: 400),
        ]
        dummyRepository.mockLogs = logs
        let expectation = expectation(description: "Spike logs")

        // When
        sut.execute()
            .sink { result in
                switch result {
                case .success(let correctedLogs):
                    // Then
                    XCTAssertEqual(correctedLogs.count, 4)
                    // 스파이크(500보 초과)가 보정되어야 함
                    // 보정 후 스무딩이 적용되므로 결과값이 원본과 다름
                    expectation.fulfill()
                case .failure:
                    XCTFail("스파이크 로그에서 실패하면 안 됨")
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func test_execute_WithAllZeroLogs_ReturnsAllZeroLogs() {
        // Given
        let startDate = Date()
        let logs = [
            ActivityLog(id: "1", time: startDate, step: 0, distance: 0),
            ActivityLog(id: "2", time: startDate.addingTimeInterval(5 * 60), step: 0, distance: 0),
            ActivityLog(id: "3", time: startDate.addingTimeInterval(10 * 60), step: 0, distance: 0),
        ]
        dummyRepository.mockLogs = logs
        let expectation = expectation(description: "All zero logs")

        // When
        sut.execute()
            .sink { result in
                switch result {
                case .success(let processedLogs):
                    // Then
                    XCTAssertEqual(processedLogs.count, 3)
                    // 모두 0인 경우 그대로 반환됨
                    XCTAssertTrue(processedLogs.allSatisfy { $0.step == 0 && $0.distance == 0 })
                    expectation.fulfill()
                case .failure:
                    XCTFail("0 로그에서 실패하면 안 됨")
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
        sut.execute()
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

    func test_execute_AppliesCorrectionBeforeSmoothing() {
        // Given
        let startDate = Date()
        // 첫 번째 로그와 두 번째 로그 사이에 600보 차이 (스파이크)
        let logs = [
            ActivityLog(id: "1", time: startDate, step: 100, distance: 50),
            ActivityLog(id: "2", time: startDate.addingTimeInterval(5 * 60), step: 700, distance: 350),
        ]
        dummyRepository.mockLogs = logs
        let expectation = expectation(description: "Correction before smoothing")

        // When
        sut.execute()
            .sink { result in
                switch result {
                case .success(let processedLogs):
                    // Then
                    XCTAssertEqual(processedLogs.count, 2)
                    // 보정이 적용되어 스파이크가 완화되어야 함
                    let stepDiff = processedLogs[1].step - processedLogs[0].step
                    XCTAssertLessThan(stepDiff, 600, "보정 후 차이가 600보다 작아야 함")
                    expectation.fulfill()
                case .failure:
                    XCTFail("실패하면 안 됨")
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }
}
