//
//  TrackActivityRepository.swift
//  Domain
//
//  Created by 김영훈 on 10/1/25.
//

import Foundation
import Combine

public protocol TrackActivityRepository {
    func requestAuthorization() -> AnyPublisher<Bool, Error>
    func startTracking(startDate: Date, mountain: Mountain)
    func getActivityLogs() -> AnyPublisher<[ActivityLog], Error>
    func stopTracking()
    func isTracking() -> AnyPublisher<Bool, Never>
    func getCurrentActivityData() -> AnyPublisher<(time: TimeInterval, steps: Int, distance: Int), Error>
    func clearTrackingData()
    func getStartDate() -> Date?
    func getClimbingMountain() -> Mountain?
    var dataUpdatePublisher: AnyPublisher<Void, Never> { get }
}
