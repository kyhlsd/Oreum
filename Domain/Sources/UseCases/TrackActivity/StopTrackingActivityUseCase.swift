//
//  StopTrackingActivityUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/1/25.
//

import Foundation
import UserNotifications
import WidgetKit

public protocol StopTrackingActivityUseCase {
    func execute(clearData: Bool)
}

public final class StopTrackingActivityUseCaseImpl: StopTrackingActivityUseCase {
    private let repository: TrackActivityRepository

    public init(repository: TrackActivityRepository) {
        self.repository = repository
    }

    public func execute(clearData: Bool = true) {
        repository.stopTracking()
        if clearData {
            repository.clearTrackingData()
        }
        cancelClimbingNotifications()
        WidgetCenter.shared.reloadAllTimelines()
    }

    // 측정 알림 취소
    private func cancelClimbingNotifications() {
        let center = UNUserNotificationCenter.current()

        // 3~12시간 알림 모두 취소
        let identifiers = (3...12).map { "climbing_reminder_\($0)" }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}
