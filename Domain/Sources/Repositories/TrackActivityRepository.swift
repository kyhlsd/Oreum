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
    func startTracking(startDate: Date)
    func getActivityLogs() -> AnyPublisher<[ActivityLog], Error>
    func stopTracking()
}
