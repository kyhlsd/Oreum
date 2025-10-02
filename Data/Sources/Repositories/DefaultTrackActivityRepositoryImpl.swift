//
//  DefaultTrackActivityRepositoryImpl.swift
//  Data
//
//  Created by 김영훈 on 10/1/25.
//

import Foundation
import Combine
import Domain

public final class DefaultTrackActivityRepositoryImpl: TrackActivityRepository {

    private let healthKitManager: HealthKitManager

    public init(healthKitManager: HealthKitManager = .shared) {
        self.healthKitManager = healthKitManager
    }

    public func requestAuthorization() -> AnyPublisher<Bool, any Error> {
        return healthKitManager.requestAuthorization()
    }

    public func startTracking(startDate: Date, mountain: Mountain) {
        healthKitManager.startTracking(startDate: startDate)
        UserDefaultHelper.startDate = startDate.timeIntervalSince1970
        UserDefaultHelper.climbingMountain = mountain
    }

    public func getActivityLogs() -> AnyPublisher<[Domain.ActivityLog], any Error> {
        guard let startTimestamp = UserDefaultHelper.startDate, startTimestamp > 0 else {
            return Fail(error: NSError(domain: "No tracking session found", code: -1)).eraseToAnyPublisher()
        }
        let startDate = Date(timeIntervalSince1970: startTimestamp)
        return healthKitManager.getActivityLogs(startDate: startDate)
    }

    public func stopTracking() {
        healthKitManager.stopTracking()
    }

    public func isTracking() -> AnyPublisher<Bool, Never> {
        let isTracking = (UserDefaultHelper.startDate ?? 0) > 0
        return Just(isTracking).eraseToAnyPublisher()
    }

    public func getCurrentActivityData() -> AnyPublisher<(time: TimeInterval, steps: Int, distance: Int), Error> {
        guard let startTimestamp = UserDefaultHelper.startDate, startTimestamp > 0 else {
            return Fail(error: NSError(domain: "No tracking session found", code: -1)).eraseToAnyPublisher()
        }
        let startDate = Date(timeIntervalSince1970: startTimestamp)
        return healthKitManager.getCurrentActivityData(startDate: startDate)
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
        return healthKitManager.healthKitUpdatePublisher
    }
}
