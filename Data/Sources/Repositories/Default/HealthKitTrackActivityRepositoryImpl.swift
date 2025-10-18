//
//  HealthKitTrackActivityRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 10/1/25.
//

import Foundation
import HealthKit
import Combine
import Domain

public final class HealthKitTrackActivityRepositoryImpl: TrackActivityRepository {

    private let healthStore = HKHealthStore()
    private var stepObserverQuery: HKObserverQuery?
    private var distanceObserverQuery: HKObserverQuery?
    private let healthKitUpdateSubject = PassthroughSubject<Void, Never>()

    public init() {}

    // MARK: - Authorization
    public func requestAuthorization() -> AnyPublisher<Result<Bool, Error>, Never> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.success(.failure(HealthKitError.repositoryDeallocated)))
                return
            }

            guard HKHealthStore.isHealthDataAvailable() else {
                promise(.success(.failure(HealthKitError.healthKitNotAvailable)))
                return
            }

            let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
            let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
            let typesToRead: Set<HKObjectType> = [stepType, distanceType]

            self.healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
                if let error = error {
                    promise(.success(.failure(error)))
                } else {
                    // 권한 요청 후 실제로 데이터를 읽을 수 있는지 확인
                    self?.testHealthKitAccess { hasAccess in
                        if hasAccess {
                            promise(.success(.success(hasAccess)))
                        } else {
                            promise(.success(.failure(HealthKitError.dataAccessDenied)))
                        }
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

        let stepQuery = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            stepAccessGranted = error == nil
            stepsCompleted = true
            if distanceCompleted {
                completion(stepAccessGranted && distanceAccessGranted)
            }
        }

        let distanceQuery = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            distanceAccessGranted = error == nil
            distanceCompleted = true
            if stepsCompleted {
                completion(stepAccessGranted && distanceAccessGranted)
            }
        }

        healthStore.execute(stepQuery)
        healthStore.execute(distanceQuery)
    }

    // MARK: - Start/Stop Tracking
    public func startTracking(startDate: Date, mountain: Mountain) {
        UserDefaultHelper.startDate = startDate.timeIntervalSince1970
        UserDefaultHelper.climbingMountain = mountain
        startObservingHealthKitChanges()
    }

    public func stopTracking() {
        stopObservingHealthKitChanges()
    }

    // MARK: - Observe HealthKit Changes
    private func startObservingHealthKitChanges() {
        // 기존 Observer가 있다면 먼저 중지
        stopObservingHealthKitChanges()

        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!

        stepObserverQuery = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, completionHandler, error in
            if error == nil {
                self?.healthKitUpdateSubject.send()
            }
            completionHandler()
        }

        distanceObserverQuery = HKObserverQuery(sampleType: distanceType, predicate: nil) { [weak self] _, completionHandler, error in
            if error == nil {
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

        healthStore.enableBackgroundDelivery(for: stepType, frequency: .immediate) { _, _ in }
        healthStore.enableBackgroundDelivery(for: distanceType, frequency: .immediate) { _, _ in }
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
    public func getActivityLogs() -> AnyPublisher<Result<[ActivityLog], Error>, Never> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.success(.failure(HealthKitError.repositoryDeallocated)))
                return
            }

            guard let startTimestamp = UserDefaultHelper.startDate, startTimestamp > 0 else {
                promise(.success(.failure(HealthKitError.noTrackingSession)))
                return
            }

            let startDate = Date(timeIntervalSince1970: startTimestamp)
            let endDate = Date()

            // 5분 간격으로 데이터 구간 생성
            var intervals: [(start: Date, end: Date)] = []
            var currentStart = startDate

            while currentStart < endDate {
                let nextInterval = currentStart.addingTimeInterval(300)
                let currentEnd = nextInterval < endDate ? nextInterval : endDate
                intervals.append((start: currentStart, end: currentEnd))
                currentStart = nextInterval
            }

            let group = DispatchGroup()
            var logs: [ActivityLog] = []

            for interval in intervals {
                group.enter()
                self.fetchStepsAndDistance(from: interval.start, to: interval.end) { steps, distance, _ in
                    let log = ActivityLog(
                        id: UUID().uuidString,
                        time: interval.end,
                        step: steps,
                        distance: distance
                    )
                    logs.append(log)
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                let initialLog = ActivityLog(
                    id: UUID().uuidString,
                    time: startDate,
                    step: 0,
                    distance: 0
                )
                logs.sort { $0.time < $1.time }
                logs.insert(initialLog, at: 0)
                promise(.success(.success(logs)))
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    public func getCurrentActivityData() -> AnyPublisher<Result<(time: TimeInterval, steps: Int, distance: Int), Error>, Never> {
        return Future { [weak self] promise in
            guard let self else {
                promise(.success(.failure(HealthKitError.repositoryDeallocated)))
                return
            }

            guard let startTimestamp = UserDefaultHelper.startDate, startTimestamp > 0 else {
                promise(.success(.failure(HealthKitError.noTrackingSession)))
                return
            }

            let startDate = Date(timeIntervalSince1970: startTimestamp)
            let endDate = Date()
            let elapsedTime = endDate.timeIntervalSince(startDate)

            self.fetchStepsAndDistance(from: startDate, to: endDate) { steps, distance, error in
                promise(.success(.success((time: elapsedTime, steps: steps, distance: distance))))
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    // MARK: - Fetch Steps and Distance
    private func fetchStepsAndDistance(from startDate: Date, to endDate: Date, completion: @escaping (Int, Int, Error?) -> Void) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        var steps: Int = 0
        var distance: Int = 0
        var stepsCompleted = false
        var distanceCompleted = false

        let stepQuery = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            if let sum = result?.sumQuantity() {
                steps = Int(sum.doubleValue(for: HKUnit.count()))
            }
            stepsCompleted = true
            if distanceCompleted {
                completion(steps, distance, nil)
            }
        }

        let distanceQuery = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            if let sum = result?.sumQuantity() {
                distance = Int(sum.doubleValue(for: HKUnit.meter()))
            }
            distanceCompleted = true
            if stepsCompleted {
                completion(steps, distance, nil)
            }
        }

        healthStore.execute(stepQuery)
        healthStore.execute(distanceQuery)
    }

    // MARK: - Tracking Status
    public func isTracking() -> AnyPublisher<Bool, Never> {
        let isTracking = (UserDefaultHelper.startDate ?? 0) > 0
        return Just(isTracking).eraseToAnyPublisher()
    }

    public func clearTrackingData() {
        UserDefaultHelper.clearStartDate()
        UserDefaultHelper.clearClimbingMountain()
    }

    public func getStartDate() -> Date? {
        guard let startTimestamp = UserDefaultHelper.startDate, startTimestamp > 0 else {
            return nil
        }
        return Date(timeIntervalSince1970: startTimestamp)
    }

    public func getClimbingMountain() -> Mountain? {
        return UserDefaultHelper.climbingMountain
    }

    public var dataUpdatePublisher: AnyPublisher<Void, Never> {
        return healthKitUpdateSubject.eraseToAnyPublisher()
    }
}
