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
    
    public func startTracking(startDate: Date) {
        healthKitManager.startTracking(startDate: startDate)
    }
    
    public func getActivityLogs() -> AnyPublisher<[Domain.ActivityLog], any Error> {
        return healthKitManager.getActivityLogs()
    }
    
    public func stopTracking() {
        healthKitManager.stopTracking()
    }
    
    
}
