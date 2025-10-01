//
//  HealthKitManager.swift
//  Data
//
//  Created by 김영훈 on 10/1/25.
//

import Foundation
import HealthKit
import Combine
import Domain

public final class HealthKitManager {

    public static let shared = HealthKitManager()

    private let healthStore = HKHealthStore()
    private var startDate: Date?

    private init() {}

    // MARK: - Authorization
    public func requestAuthorization() -> AnyPublisher<Bool, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "HealthKitManager", code: -1)))
                return
            }

            guard HKHealthStore.isHealthDataAvailable() else {
                promise(.failure(NSError(domain: "HealthKit not available", code: -1)))
                return
            }

            let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
            let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!

            let typesToRead: Set<HKObjectType> = [stepType, distanceType]

            self.healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(success))
                }
            }
        }.eraseToAnyPublisher()
    }

    // MARK: - Start Tracking
    public func startTracking(startDate: Date) {
        self.startDate = startDate
        UserDefaults.standard.set(startDate.timeIntervalSince1970, forKey: "trackingStartDate")
        print("✅ Tracking started at: \(startDate)")
    }

    // MARK: - Get Activity Data
    public func getActivityLogs() -> AnyPublisher<[ActivityLog], Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "HealthKitManager", code: -1)))
                return
            }

            // UserDefaults에서 시작 시간 복원
            let startTimestamp = UserDefaults.standard.double(forKey: "trackingStartDate")
            guard startTimestamp > 0 else {
                promise(.failure(NSError(domain: "No tracking session found", code: -1)))
                return
            }

            let startDate = Date(timeIntervalSince1970: startTimestamp)
            let endDate = Date()

            // 5분 간격으로 데이터 구간 생성
            var intervals: [(start: Date, end: Date)] = []
            var currentStart = startDate

            while currentStart < endDate {
                let currentEnd = min(currentStart.addingTimeInterval(300), endDate) // 5분 = 300초
                intervals.append((start: currentStart, end: currentEnd))
                currentStart = currentEnd
            }

            let group = DispatchGroup()
            var logs: [ActivityLog] = []
            var fetchError: Error?

            // 각 구간에 대해 걸음 수와 거리 가져오기
            for (index, interval) in intervals.enumerated() {
                group.enter()

                self.fetchStepsAndDistance(from: interval.start, to: interval.end) { steps, distance, error in
                    if let error = error {
                        fetchError = error
                    } else {
                        let log = ActivityLog(
                            id: UUID().uuidString,
                            time: interval.start,
                            step: steps,
                            distance: distance
                        )
                        logs.append(log)
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                if let error = fetchError {
                    promise(.failure(error))
                } else {
                    // 시간 순으로 정렬
                    logs.sort { $0.time < $1.time }
                    promise(.success(logs))
                }
            }
        }.eraseToAnyPublisher()
    }

    // MARK: - Fetch Steps and Distance for Interval
    private func fetchStepsAndDistance(from startDate: Date, to endDate: Date, completion: @escaping (Int, Int, Error?) -> Void) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        var steps: Int = 0
        var distance: Int = 0
        var stepsCompleted = false
        var distanceCompleted = false
        var queryError: Error?

        // 걸음 수 쿼리
        let stepQuery = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            if let error = error {
                queryError = error
            } else if let sum = result?.sumQuantity() {
                steps = Int(sum.doubleValue(for: HKUnit.count()))
            }
            stepsCompleted = true

            if distanceCompleted {
                completion(steps, distance, queryError)
            }
        }

        // 거리 쿼리
        let distanceQuery = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            if let error = error {
                queryError = error
            } else if let sum = result?.sumQuantity() {
                distance = Int(sum.doubleValue(for: HKUnit.meter()))
            }
            distanceCompleted = true

            if stepsCompleted {
                completion(steps, distance, queryError)
            }
        }

        healthStore.execute(stepQuery)
        healthStore.execute(distanceQuery)
    }

    // MARK: - Stop Tracking
    public func stopTracking() {
        UserDefaults.standard.removeObject(forKey: "trackingStartDate")
        startDate = nil
        print("✅ Tracking stopped")
    }
}
