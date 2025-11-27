//
//  ActivityStatUseCaseTests.swift
//  DomainTests
//
//  Created by 김영훈 on 2025-11-28.
//

import XCTest
@testable import Domain

final class ActivityStatUseCaseTests: XCTestCase {

    var sut: ActivityStatUseCaseImpl!

    override func setUp() {
        super.setUp()
        sut = ActivityStatUseCaseImpl()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_execute_WithEmptyLogs_ReturnsZeroStats() {
        // Given
        let logs: [ActivityLog] = []

        // When
        let result = sut.execute(activityLogs: logs)

        // Then
        XCTAssertEqual(result.totalTimeMinutes, 0)
        XCTAssertEqual(result.totalDistance, 0)
        XCTAssertEqual(result.totalSteps, 0)
        XCTAssertNil(result.startTime)
        XCTAssertNil(result.endTime)
        XCTAssertEqual(result.exerciseMinutes, 0)
        XCTAssertEqual(result.restMinutes, 0)
    }

    func test_execute_WithSingleInitialLog_ReturnsZeroStats() {
        // Given
        let startDate = Date()
        let logs = [
            ActivityLog(id: "1", time: startDate, step: 0, distance: 0)
        ]

        // When
        let result = sut.execute(activityLogs: logs)

        // Then
        XCTAssertEqual(result.totalTimeMinutes, 0)
        XCTAssertEqual(result.totalDistance, 0)
        XCTAssertEqual(result.totalSteps, 0)
        XCTAssertEqual(result.startTime, startDate)
        XCTAssertEqual(result.endTime, startDate)
        XCTAssertEqual(result.exerciseMinutes, 0)
        XCTAssertEqual(result.restMinutes, 0)
    }

    func test_execute_WithInitialLogOnly_CountsAsRest() {
        // Given
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(30 * 60) // 30분 후
        let logs = [
            ActivityLog(id: "1", time: startDate, step: 0, distance: 0),
            ActivityLog(id: "2", time: endDate, step: 0, distance: 0)
        ]

        // When
        let result = sut.execute(activityLogs: logs)

        // Then
        XCTAssertEqual(result.totalTimeMinutes, 30)
        XCTAssertEqual(result.exerciseMinutes, 0, "모든 걸음이 0이면 운동 시간은 0")
        XCTAssertEqual(result.restMinutes, 30, "모든 걸음이 0이면 전체 시간을 휴식 시간으로 계산")
    }

    func test_execute_WithExerciseLogs_CalculatesCorrectExerciseTime() {
        // Given
        let startDate = Date()
        let logs = [
            ActivityLog(id: "1", time: startDate, step: 0, distance: 0),
            ActivityLog(id: "2", time: startDate.addingTimeInterval(5 * 60), step: 150, distance: 100), // 5분 후, 150걸음 (운동)
            ActivityLog(id: "3", time: startDate.addingTimeInterval(10 * 60), step: 200, distance: 150), // 10분 후, 200걸음 (운동)
        ]

        // When
        let result = sut.execute(activityLogs: logs)

        // Then
        XCTAssertEqual(result.totalTimeMinutes, 10)
        XCTAssertEqual(result.totalSteps, 350, "150 + 200 = 350")
        XCTAssertEqual(result.totalDistance, 250, "100 + 150 = 250")
        XCTAssertEqual(result.exerciseMinutes, 10, "5분당 100걸음 이상이므로 운동 시간")
        XCTAssertEqual(result.restMinutes, 0)
    }

    func test_execute_WithRestLogs_CalculatesCorrectRestTime() {
        // Given
        let startDate = Date()
        let logs = [
            ActivityLog(id: "1", time: startDate, step: 0, distance: 0),
            ActivityLog(id: "2", time: startDate.addingTimeInterval(5 * 60), step: 50, distance: 30), // 5분 후, 50걸음 (휴식)
            ActivityLog(id: "3", time: startDate.addingTimeInterval(10 * 60), step: 80, distance: 50), // 10분 후, 80걸음 (휴식)
        ]

        // When
        let result = sut.execute(activityLogs: logs)

        // Then
        XCTAssertEqual(result.totalTimeMinutes, 10)
        XCTAssertEqual(result.exerciseMinutes, 0, "5분당 100걸음 미만이므로 휴식 시간")
        XCTAssertEqual(result.restMinutes, 10)
    }

    func test_execute_WithMixedLogs_CalculatesMixedExerciseAndRest() {
        // Given
        let startDate = Date()
        let logs = [
            ActivityLog(id: "1", time: startDate, step: 0, distance: 0),
            ActivityLog(id: "2", time: startDate.addingTimeInterval(5 * 60), step: 150, distance: 100), // 운동
            ActivityLog(id: "3", time: startDate.addingTimeInterval(10 * 60), step: 50, distance: 30),  // 휴식
            ActivityLog(id: "4", time: startDate.addingTimeInterval(15 * 60), step: 200, distance: 150), // 운동
        ]

        // When
        let result = sut.execute(activityLogs: logs)

        // Then
        XCTAssertEqual(result.totalTimeMinutes, 15)
        XCTAssertEqual(result.totalSteps, 400)
        XCTAssertEqual(result.totalDistance, 280)
        XCTAssertEqual(result.exerciseMinutes, 10, "5분(운동) + 5분(운동) = 10분")
        XCTAssertEqual(result.restMinutes, 5, "5분(휴식)")
    }

    func test_execute_WithLastLogLowStepsPerMinute_CountsAsRest() {
        // Given
        let startDate = Date()
        let logs = [
            ActivityLog(id: "1", time: startDate, step: 0, distance: 0),
            ActivityLog(id: "2", time: startDate.addingTimeInterval(5 * 60), step: 150, distance: 100), // 운동
            ActivityLog(id: "3", time: startDate.addingTimeInterval(10 * 60), step: 50, distance: 30),  // 마지막 로그, 분당 10보 (휴식)
        ]

        // When
        let result = sut.execute(activityLogs: logs)

        // Then
        XCTAssertEqual(result.totalTimeMinutes, 10)
        XCTAssertEqual(result.exerciseMinutes, 5, "첫 번째 구간만 운동")
        XCTAssertEqual(result.restMinutes, 5, "마지막 로그가 분당 20보 미만이므로 휴식")
    }

    func test_execute_WithLastLogHighStepsPerMinute_CountsAsExercise() {
        // Given
        let startDate = Date()
        let logs = [
            ActivityLog(id: "1", time: startDate, step: 0, distance: 0),
            ActivityLog(id: "2", time: startDate.addingTimeInterval(5 * 60), step: 150, distance: 100), // 운동
            ActivityLog(id: "3", time: startDate.addingTimeInterval(10 * 60), step: 150, distance: 100), // 마지막 로그, 분당 30보 (운동)
        ]

        // When
        let result = sut.execute(activityLogs: logs)

        // Then
        XCTAssertEqual(result.totalTimeMinutes, 10)
        XCTAssertEqual(result.exerciseMinutes, 10, "모든 구간이 운동")
        XCTAssertEqual(result.restMinutes, 0)
    }

    func test_execute_ReturnsCorrectStartAndEndTime() {
        // Given
        let startDate = Date(timeIntervalSince1970: 1000000)
        let endDate = Date(timeIntervalSince1970: 1001800) // 30분 후
        let logs = [
            ActivityLog(id: "1", time: startDate, step: 0, distance: 0),
            ActivityLog(id: "2", time: endDate, step: 150, distance: 100),
        ]

        // When
        let result = sut.execute(activityLogs: logs)

        // Then
        XCTAssertEqual(result.startTime, startDate)
        XCTAssertEqual(result.endTime, endDate)
    }
}
