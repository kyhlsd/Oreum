//
//  GetRecordStatsUseCaseTests.swift
//  DomainTests
//
//  Created by 김영훈 on 2025-11-28.
//

import XCTest
@testable import Domain

final class GetRecordStatsUseCaseTests: XCTestCase {

    var sut: GetRecordStatsUseCaseImpl!

    override func setUp() {
        super.setUp()
        sut = GetRecordStatsUseCaseImpl()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_execute_WithEmptyRecords_ReturnsZeroStats() {
        // Given
        let records: [ClimbRecord] = []

        // When
        let result = sut.execute(records: records)

        // Then
        XCTAssertEqual(result.mountainCount, 0)
        XCTAssertEqual(result.climbCount, 0)
        XCTAssertEqual(result.totalHeight, 0)
    }

    func test_execute_WithSingleRecord_ReturnsCorrectStats() {
        // Given
        let mountain = Mountain(id: 1, name: "한라산", address: "제주", height: 1950, isFamous: true)
        let record = ClimbRecord(
            id: "1",
            mountain: mountain,
            timeLog: [],
            images: [],
            score: 5,
            comment: "",
            isBookmarked: false,
            climbDate: Date()
        )

        // When
        let result = sut.execute(records: [record])

        // Then
        XCTAssertEqual(result.mountainCount, 1)
        XCTAssertEqual(result.climbCount, 1)
        XCTAssertEqual(result.totalHeight, 1950)
    }

    func test_execute_WithMultipleRecordsSameMountain_ReturnsCorrectMountainCount() {
        // Given
        let mountain = Mountain(id: 1, name: "한라산", address: "제주", height: 1950, isFamous: true)
        let record1 = ClimbRecord(
            id: "1",
            mountain: mountain,
            timeLog: [],
            images: [],
            score: 5,
            comment: "",
            isBookmarked: false,
            climbDate: Date()
        )
        let record2 = ClimbRecord(
            id: "2",
            mountain: mountain,
            timeLog: [],
            images: [],
            score: 4,
            comment: "",
            isBookmarked: false,
            climbDate: Date()
        )

        // When
        let result = sut.execute(records: [record1, record2])

        // Then
        XCTAssertEqual(result.mountainCount, 1, "같은 산을 여러 번 등산해도 고유 산 개수는 1개여야 함")
        XCTAssertEqual(result.climbCount, 2, "등산 횟수는 2회여야 함")
        XCTAssertEqual(result.totalHeight, 3900, "총 높이는 1950 * 2 = 3900")
    }

    func test_execute_WithMultipleRecordsDifferentMountains_ReturnsCorrectStats() {
        // Given
        let mountain1 = Mountain(id: 1, name: "한라산", address: "제주", height: 1950, isFamous: true)
        let mountain2 = Mountain(id: 2, name: "설악산", address: "강원", height: 1708, isFamous: true)
        let mountain3 = Mountain(id: 3, name: "북한산", address: "서울", height: 836, isFamous: true)

        let record1 = ClimbRecord(id: "1", mountain: mountain1, timeLog: [], images: [], score: 5, comment: "", isBookmarked: false, climbDate: Date())
        let record2 = ClimbRecord(id: "2", mountain: mountain2, timeLog: [], images: [], score: 4, comment: "", isBookmarked: false, climbDate: Date())
        let record3 = ClimbRecord(id: "3", mountain: mountain3, timeLog: [], images: [], score: 3, comment: "", isBookmarked: false, climbDate: Date())

        // When
        let result = sut.execute(records: [record1, record2, record3])

        // Then
        XCTAssertEqual(result.mountainCount, 3)
        XCTAssertEqual(result.climbCount, 3)
        XCTAssertEqual(result.totalHeight, 4494, "총 높이는 1950 + 1708 + 836 = 4494")
    }

    func test_execute_WithMountainWithoutHeight_IgnoresNilHeight() {
        // Given
        let mountain1 = Mountain(id: 1, name: "한라산", address: "제주", height: 1950, isFamous: true)
        let mountain2 = Mountain(id: 2, name: "무명산", address: "어딘가", height: nil, isFamous: false)

        let record1 = ClimbRecord(id: "1", mountain: mountain1, timeLog: [], images: [], score: 5, comment: "", isBookmarked: false, climbDate: Date())
        let record2 = ClimbRecord(id: "2", mountain: mountain2, timeLog: [], images: [], score: 4, comment: "", isBookmarked: false, climbDate: Date())

        // When
        let result = sut.execute(records: [record1, record2])

        // Then
        XCTAssertEqual(result.mountainCount, 2)
        XCTAssertEqual(result.climbCount, 2)
        XCTAssertEqual(result.totalHeight, 1950, "nil 높이는 무시되고 1950만 계산됨")
    }

    func test_execute_WithMixedRecords_ReturnsCorrectStats() {
        // Given
        let mountain1 = Mountain(id: 1, name: "한라산", address: "제주", height: 1950, isFamous: true)
        let mountain2 = Mountain(id: 2, name: "설악산", address: "강원", height: 1708, isFamous: true)

        // 한라산 2회, 설악산 1회
        let record1 = ClimbRecord(id: "1", mountain: mountain1, timeLog: [], images: [], score: 5, comment: "", isBookmarked: false, climbDate: Date())
        let record2 = ClimbRecord(id: "2", mountain: mountain2, timeLog: [], images: [], score: 4, comment: "", isBookmarked: false, climbDate: Date())
        let record3 = ClimbRecord(id: "3", mountain: mountain1, timeLog: [], images: [], score: 5, comment: "", isBookmarked: false, climbDate: Date())

        // When
        let result = sut.execute(records: [record1, record2, record3])

        // Then
        XCTAssertEqual(result.mountainCount, 2, "2개의 고유한 산")
        XCTAssertEqual(result.climbCount, 3, "총 3회 등산")
        XCTAssertEqual(result.totalHeight, 5608, "1950 * 2 + 1708 = 5608")
    }
}
