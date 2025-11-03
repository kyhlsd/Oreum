//
//  Provider.swift
//  OreumWidget
//
//  Created by 김영훈 on 11/4/25.
//

import WidgetKit
import Core

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> MeasurementEntry {
        MeasurementEntry(date: Date(), measurementState: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (MeasurementEntry) -> Void) {
        let entry = createEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MeasurementEntry>) -> Void) {
        let currentDate = Date()
        let entry = createEntry()

        // 측정 중일 때는 1분마다 업데이트, 아닐 때는 1시간마다 업데이트
        let refreshInterval: TimeInterval = entry.measurementState.isMeasuring ? 60 : 3600

        let nextUpdateDate = Calendar.current.date(byAdding: .second, value: Int(refreshInterval), to: currentDate)!

        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }

    private func createEntry() -> MeasurementEntry {
        let userDefaults = UserDefaultsManager.shared

        if let startDate = userDefaults.startDate,
           let mountainName = userDefaults.climbingMountain?.name {
            return MeasurementEntry(
                date: Date(),
                measurementState: .measuring(mountainName: mountainName, startDate: startDate)
            )
        } else {
            return MeasurementEntry(date: Date(), measurementState: .idle)
        }
    }
}
