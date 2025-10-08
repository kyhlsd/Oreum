//
//  DummyTrackActivityRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 10/8/25.
//

import Foundation
import Combine
import Domain

public final class DummyTrackActivityRepositoryImpl: TrackActivityRepository {

    private var startDate: Date?
    private var climbingMountain: Mountain?
    private let dataUpdateSubject = PassthroughSubject<Void, Never>()
    private var timer: Timer?

    public init() {}

    public func requestAuthorization() -> AnyPublisher<Bool, Error> {
        return Just(true)
            .setFailureType(to: Error.self)
            .delay(for: .seconds(0.5), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }

    public func startTracking(startDate: Date, mountain: Mountain) {
        self.startDate = startDate
        self.climbingMountain = mountain

        // 1초마다 데이터 업데이트 알림
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.dataUpdateSubject.send(())
        }
    }

    public func getActivityLogs() -> AnyPublisher<[ActivityLog], Error> {
        guard let startDate = self.startDate else {
            return Fail(error: NSError(domain: "No tracking session found", code: -1))
                .eraseToAnyPublisher()
        }

        let endDate = Date()
        let intervals = createIntervals(startDate: startDate, endDate: endDate)

        let logs = intervals.map { interval in
            let steps = Int.random(in: 50...150)
            let distance = Int.random(in: 40...120)
            return ActivityLog(
                id: UUID().uuidString,
                time: interval.end,
                step: steps,
                distance: distance
            )
        }

        return Just(logs)
            .setFailureType(to: Error.self)
            .delay(for: .seconds(0.3), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }

    public func stopTracking() {
        timer?.invalidate()
        timer = nil
    }

    public func isTracking() -> AnyPublisher<Bool, Never> {
        return Just(startDate != nil)
            .eraseToAnyPublisher()
    }

    public func getCurrentActivityData() -> AnyPublisher<(time: TimeInterval, steps: Int, distance: Int), Error> {
        guard let startDate = self.startDate else {
            return Fail(error: NSError(domain: "No tracking session found", code: -1))
                .eraseToAnyPublisher()
        }

        let elapsedTime = Date().timeIntervalSince(startDate)
        let steps = Int(elapsedTime / 10) * Int.random(in: 8...12) // 대략 10초당 10걸음
        let distance = Int(elapsedTime / 10) * Int.random(in: 7...13) // 대략 10초당 10m

        return Just((time: elapsedTime, steps: steps, distance: distance))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    public func clearTrackingData() {
        startDate = nil
        climbingMountain = nil
    }

    public func getStartDate() -> Date? {
        return startDate
    }

    public func getClimbingMountain() -> Mountain? {
        return climbingMountain
    }

    public var dataUpdatePublisher: AnyPublisher<Void, Never> {
        return dataUpdateSubject.eraseToAnyPublisher()
    }

    // MARK: - Helper Methods
    private func createIntervals(startDate: Date, endDate: Date) -> [(start: Date, end: Date)] {
        var intervals: [(start: Date, end: Date)] = []
        var currentStart = startDate

        // 초기 로그 (0/0)
        intervals.append((start: currentStart, end: currentStart))

        // 5분 간격으로 나누기
        while currentStart < endDate {
            let nextInterval = currentStart.addingTimeInterval(300) // 5분
            let currentEnd = nextInterval < endDate ? nextInterval : endDate
            intervals.append((start: currentStart, end: currentEnd))
            currentStart = nextInterval
        }

        return intervals
    }
}
