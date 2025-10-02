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
    private var stepObserverQuery: HKObserverQuery?
    private var distanceObserverQuery: HKObserverQuery?
    private let healthKitUpdateSubject = PassthroughSubject<Void, Never>()

    public var healthKitUpdatePublisher: AnyPublisher<Void, Never> {
        healthKitUpdateSubject.eraseToAnyPublisher()
    }

    private init() {}

    // MARK: - Authorization
    public func requestAuthorization() -> AnyPublisher<Bool, Error> {
        return Future { [weak self] promise in
            guard let self else {
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

            self.healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    // 권한 요청 후 실제로 데이터를 읽을 수 있는지 확인
                    self?.testHealthKitAccess { hasAccess in
                        promise(.success(hasAccess))
                    }
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    // 실제로 HealthKit 데이터에 접근할 수 있는지 테스트
    private func testHealthKitAccess(completion: @escaping (Bool) -> Void) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let now = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: now)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)

        var stepAccessGranted = false
        var distanceAccessGranted = false
        var stepsCompleted = false
        var distanceCompleted = false

        // 걸음 수 쿼리
        let stepQuery = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            if error != nil {
                stepAccessGranted = false
            } else {
                stepAccessGranted = true
            }
            stepsCompleted = true

            if distanceCompleted {
                completion(stepAccessGranted && distanceAccessGranted)
            }
        }

        // 거리 쿼리
        let distanceQuery = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            if error != nil {
                distanceAccessGranted = false
            } else {
                distanceAccessGranted = true
            }
            distanceCompleted = true

            if stepsCompleted {
                completion(stepAccessGranted && distanceAccessGranted)
            }
        }

        healthStore.execute(stepQuery)
        healthStore.execute(distanceQuery)
    }

    // MARK: - Start Tracking
    public func startTracking(startDate: Date) {
        self.startDate = startDate
        startObservingHealthKitChanges()
        print("✅ Tracking started at: \(startDate)")
    }

    // MARK: - Observe HealthKit Changes
    private func startObservingHealthKitChanges() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!

        // Step Observer
        stepObserverQuery = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, completionHandler, error in
            if let error = error {
                print("❌ Step observer error: \(error)")
            } else {
                print("✅ Step data changed")
                self?.healthKitUpdateSubject.send()
            }
            completionHandler()
        }

        // Distance Observer
        distanceObserverQuery = HKObserverQuery(sampleType: distanceType, predicate: nil) { [weak self] _, completionHandler, error in
            if let error = error {
                print("❌ Distance observer error: \(error)")
            } else {
                print("✅ Distance data changed")
                self?.healthKitUpdateSubject.send()
            }
            completionHandler()
        }

        if let stepQuery = stepObserverQuery {
            healthStore.execute(stepQuery)
        }
        if let distanceQuery = distanceObserverQuery {
            healthStore.execute(distanceQuery)
        }

        // Background delivery 활성화
        healthStore.enableBackgroundDelivery(for: stepType, frequency: .immediate) { success, error in
            if success {
                print("✅ Background delivery enabled for steps")
            } else {
                print("❌ Failed to enable background delivery for steps: \(String(describing: error))")
            }
        }

        healthStore.enableBackgroundDelivery(for: distanceType, frequency: .immediate) { success, error in
            if success {
                print("✅ Background delivery enabled for distance")
            } else {
                print("❌ Failed to enable background delivery for distance: \(String(describing: error))")
            }
        }
    }

    private func stopObservingHealthKitChanges() {
        if let stepQuery = stepObserverQuery {
            healthStore.stop(stepQuery)
            stepObserverQuery = nil
        }
        if let distanceQuery = distanceObserverQuery {
            healthStore.stop(distanceQuery)
            distanceObserverQuery = nil
        }

        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!

        healthStore.disableBackgroundDelivery(for: stepType) { _, _ in }
        healthStore.disableBackgroundDelivery(for: distanceType) { _, _ in }
    }

    // MARK: - Get Activity Data
    public func getActivityLogs(startDate: Date) -> AnyPublisher<[ActivityLog], Error> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.failure(NSError(domain: "HealthKitManager", code: -1)))
                return
            }

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
            for interval in intervals {
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
                // 초기값 추가 (시작 시간, 걸음수 0, 이동 거리 0)
                let initialLog = ActivityLog(
                    id: UUID().uuidString,
                    time: startDate,
                    step: 0,
                    distance: 0
                )

                // 종료 시간의 누적 걸음수와 이동거리 계산
                let totalSteps = logs.reduce(0) { $0 + $1.step }
                let totalDistance = logs.reduce(0) { $0 + $1.distance }

                // 종료값 추가 (종료 시간, 누적 걸음수, 누적 이동 거리)
                let finalLog = ActivityLog(
                    id: UUID().uuidString,
                    time: endDate,
                    step: totalSteps,
                    distance: totalDistance
                )

                if let error = fetchError {
                    // 에러가 발생해도 초기값과 종료값은 반환
                    promise(.success([initialLog, finalLog]))
                } else {
                    // 시간 순으로 정렬
                    logs.sort { $0.time < $1.time }
                    logs.insert(initialLog, at: 0)
                    logs.append(finalLog)
                    promise(.success(logs))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
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
        stopObservingHealthKitChanges()
        startDate = nil
        print("✅ Tracking stopped")
    }

    // MARK: - Check Tracking Status
    public func isTracking() -> Bool {
        return startDate != nil
    }

    // MARK: - Get Current Activity Data
    public func getCurrentActivityData(startDate: Date) -> AnyPublisher<(time: TimeInterval, steps: Int, distance: Int), Error> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.failure(NSError(domain: "HealthKitManager", code: -1)))
                return
            }
            let endDate = Date()
            let elapsedTime = endDate.timeIntervalSince(startDate)

            self.fetchStepsAndDistance(from: startDate, to: endDate) { steps, distance, error in
                // 에러가 발생해도 시간은 표시
                promise(.success((time: elapsedTime, steps: steps, distance: distance)))
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
