//
//  StartTrackingActivityUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/1/25.
//

import Foundation
import UserNotifications
import WidgetKit

public protocol StartTrackingActivityUseCase {
    func execute(startDate: Date, mountain: Mountain)
    func getStartDate() -> Date?
}

public final class StartTrackingActivityUseCaseImpl: StartTrackingActivityUseCase {
    private let repository: TrackActivityRepository

    public init(repository: TrackActivityRepository) {
        self.repository = repository
    }

    public func execute(startDate: Date, mountain: Mountain) {
        repository.startTracking(startDate: startDate, mountain: mountain)
        scheduleClimbingNotifications()
        WidgetCenter.shared.reloadAllTimelines()
    }

    public func getStartDate() -> Date? {
        return repository.getStartDate()
    }

    // 측정 중 알림 스케줄링
    private func scheduleClimbingNotifications() {
        let center = UNUserNotificationCenter.current()

        // 알림 권한 요청
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }

            // 3시간 후부터 1시간 간격으로 알림 (최대 12시간까지)
            let startHour = 3
            let endHour = 12

            for hour in stride(from: startHour, through: endHour, by: 1) {
                let content = UNMutableNotificationContent()
                content.title = "등산 측정 중"
                content.body = "등산을 측정한지 \(hour)시간이 지났습니다. 등산을 마쳤다면 측정을 종료해주세요."
                content.sound = .default

                let trigger = UNTimeIntervalNotificationTrigger(
                    timeInterval: TimeInterval(hour * 3600),
                    repeats: false
                )

                let request = UNNotificationRequest(
                    identifier: "climbing_reminder_\(hour)",
                    content: content,
                    trigger: trigger
                )

                center.add(request)
            }
        }
    }
}
