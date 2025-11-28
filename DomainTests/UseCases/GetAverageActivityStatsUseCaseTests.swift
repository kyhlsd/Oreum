//
//  GetAverageActivityStatsUseCaseTests.swift
//  DomainTests
//
//  Created by 김영훈 on 2025-11-28.
//

import XCTest
import Combine
@testable import Domain
@testable import Data

final class GetAverageActivityStatsUseCaseTests: XCTestCase {

    var sut: GetAverageActivityStatsUseCaseImpl!
    var dummyRepository: DummyClimbRecordRepositoryImpl!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        dummyRepository = DummyClimbRecordRepositoryImpl()
        dummyRepository.useMockData = true
        sut = GetAverageActivityStatsUseCaseImpl(repository: dummyRepository)
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        sut = nil
        dummyRepository = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_execute_WithEmptyRecords_ReturnsEmptyStats() {
        // Given
        dummyRepository.mockRecords = []
        let expectation = expectation(description: "Empty records")

        // When
        sut.execute()
            .sink { result in
                switch result {
                case .success(let stats):
                    // Then
                    XCTAssertEqual(stats.averageTotalMinutes, 0)
                    XCTAssertEqual(stats.averageExerciseMinutes, 0)
                    XCTAssertEqual(stats.averageRestMinutes, 0)
                    XCTAssertEqual(stats.averageSpeed, 0.0)
                    expectation.fulfill()
                case .failure:
                    XCTFail("빈 레코드에서 실패하면 안 됨")
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func test_execute_WithRecordsWithoutTimeLogs_ReturnsEmptyStats() {
        // Given
        let mountain = Mountain(id: 1, name: "한라산", address: "제주", height: 1950, isFamous: true)
        let record = ClimbRecord(
            id: "1",
            mountain: mountain,
            timeLog: [], // 시간 로그 없음
            images: [],
            score: 5,
            comment: "",
            isBookmarked: false,
            climbDate: Date()
        )
        dummyRepository.mockRecords = [record]
        let expectation = expectation(description: "No time logs")

        // When
        sut.execute()
            .sink { result in
                switch result {
                case .success(let stats):
                    // Then
                    XCTAssertEqual(stats.averageTotalMinutes, 0)
                    XCTAssertEqual(stats.averageExerciseMinutes, 0)
                    XCTAssertEqual(stats.averageRestMinutes, 0)
                    XCTAssertEqual(stats.averageSpeed, 0.0)
                    expectation.fulfill()
                case .failure:
                    XCTFail("빈 시간 로그에서 실패하면 안 됨")
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func test_execute_WithSingleValidRecord_CalculatesCorrectAverages() {
        // Given
        let startDate = Date()
        let timeLogs = [
            ActivityLog(id: "1", time: startDate, step: 0, distance: 0),
            ActivityLog(id: "2", time: startDate.addingTimeInterval(5 * 60), step: 150, distance: 300), // 운동
            ActivityLog(id: "3", time: startDate.addingTimeInterval(10 * 60), step: 50, distance: 100),  // 휴식
            ActivityLog(id: "4", time: startDate.addingTimeInterval(15 * 60), step: 200, distance: 400), // 운동
        ]
        let mountain = Mountain(id: 1, name: "한라산", address: "제주", height: 1950, isFamous: true)
        let record = ClimbRecord(
            id: "1",
            mountain: mountain,
            timeLog: timeLogs,
            images: [],
            score: 5,
            comment: "",
            isBookmarked: false,
            climbDate: Date()
        )
        dummyRepository.mockRecords = [record]
        let expectation = expectation(description: "Single valid record")

        // When
        sut.execute()
            .sink { result in
                switch result {
                case .success(let stats):
                    // Then
                    XCTAssertEqual(stats.averageTotalMinutes, 15, "총 15분")
                    XCTAssertEqual(stats.averageExerciseMinutes, 10, "운동 시간 10분")
                    XCTAssertEqual(stats.averageRestMinutes, 5, "휴식 시간 5분")

                    let expectedSpeed = 800.0 / 15.0 // 총 거리 / 총 시간
                    XCTAssertEqual(stats.averageSpeed, expectedSpeed, accuracy: 0.01)
                    expectation.fulfill()
                case .failure:
                    XCTFail("유효한 레코드에서 실패하면 안 됨")
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func test_execute_WithMultipleValidRecords_CalculatesCorrectAverages() {
        // Given
        let startDate = Date()

        // 첫 번째 레코드: 20분 등산 (운동 15분, 휴식 5분, 거리 1000m)
        let timeLogs1 = [
            ActivityLog(id: "1", time: startDate, step: 0, distance: 0),
            ActivityLog(id: "2", time: startDate.addingTimeInterval(5 * 60), step: 150, distance: 300),
            ActivityLog(id: "3", time: startDate.addingTimeInterval(10 * 60), step: 50, distance: 100),
            ActivityLog(id: "4", time: startDate.addingTimeInterval(15 * 60), step: 200, distance: 400),
            ActivityLog(id: "5", time: startDate.addingTimeInterval(20 * 60), step: 150, distance: 200),
        ]

        // 두 번째 레코드: 10분 등산 (운동 5분, 휴식 5분, 거리 400m)
        let timeLogs2 = [
            ActivityLog(id: "6", time: startDate, step: 0, distance: 0),
            ActivityLog(id: "7", time: startDate.addingTimeInterval(5 * 60), step: 150, distance: 300),
            ActivityLog(id: "8", time: startDate.addingTimeInterval(10 * 60), step: 50, distance: 100),
        ]

        let mountain = Mountain(id: 1, name: "한라산", address: "제주", height: 1950, isFamous: true)
        let record1 = ClimbRecord(id: "1", mountain: mountain, timeLog: timeLogs1, images: [], score: 5, comment: "", isBookmarked: false, climbDate: Date())
        let record2 = ClimbRecord(id: "2", mountain: mountain, timeLog: timeLogs2, images: [], score: 4, comment: "", isBookmarked: false, climbDate: Date())

        dummyRepository.mockRecords = [record1, record2]
        let expectation = expectation(description: "Multiple valid records")

        // When
        sut.execute()
            .sink { result in
                switch result {
                case .success(let stats):
                    // Then
                    // 평균 총 시간: (20 + 10) / 2 = 15분
                    XCTAssertEqual(stats.averageTotalMinutes, 15)

                    // 평균 운동 시간: (15 + 5) / 2 = 10분
                    XCTAssertEqual(stats.averageExerciseMinutes, 10)

                    // 평균 휴식 시간: (5 + 5) / 2 = 5분
                    XCTAssertEqual(stats.averageRestMinutes, 5)

                    // 평균 속도: 1400 / 30 ≈ 46.67 m/m
                    let expectedSpeed = (1000.0 + 400.0) / (20.0 + 10.0)
                    XCTAssertEqual(stats.averageSpeed, expectedSpeed, accuracy: 0.01)
                    expectation.fulfill()
                case .failure:
                    XCTFail("유효한 레코드에서 실패하면 안 됨")
                }
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func test_execute_WithMixedRecords_FiltersOutEmptyTimeLogs() {
        // Given
        let startDate = Date()
        let timeLogs = [
            ActivityLog(id: "1", time: startDate, step: 0, distance: 0),
            ActivityLog(id: "2", time: startDate.addingTimeInterval(10 * 60), step: 200, distance: 500),
        ]

        let mountain = Mountain(id: 1, name: "한라산", address: "제주", height: 1950, isFamous: true)
        let recordWithLogs = ClimbRecord(id: "1", mountain: mountain, timeLog: timeLogs, images: [], score: 5, comment: "", isBookmarked: false, climbDate: Date())
        let recordWithoutLogs = ClimbRecord(id: "2", mountain: mountain, timeLog: [], images: [], score: 4, comment: "", isBookmarked: false, climbDate: Date())

        dummyRepository.mockRecords = [recordWithLogs, recordWithoutLogs]
        let expectation = expectation(description: "Mixed records")

        // When
        sut.execute()
            .sink { result in
                switch result {
                case .success(let stats):
                    // Then
                    // 빈 로그를 가진 레코드는 제외되고, 유효한 레코드 1개만 계산됨
                    XCTAssertEqual(stats.averageTotalMinutes, 10)
                    expectation.fulfill()
                case .failure:
                    XCTFail("실패하면 안 됨")
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
}
