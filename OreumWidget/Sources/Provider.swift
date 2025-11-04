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
        let firstEntry = createEntry(for: currentDate)

        // 측정 중일 때는 향후 12시간 동안의 entry들을 5분 간격으로 생성
        if firstEntry.measurementState.isMeasuring {
            var entries: [MeasurementEntry] = []

            // 144개의 entry 생성 (5분 간격으로 12시간)
            for minuteOffset in stride(from: 0, to: 720, by: 5) {
                let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
                let entry = createEntry(for: entryDate)
                entries.append(entry)
            }

            // 마지막 entry 이후에 새로운 타임라인 요청
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        } else {
            // 측정 중이 아닐 때는 업데이트 안함
            let timeline = Timeline(entries: [firstEntry], policy: .never)
            completion(timeline)
        }
    }

    private func createEntry(for date: Date = Date()) -> MeasurementEntry {
        let userDefaults = UserDefaultsManager.shared

        if let startDate = userDefaults.startDate,
           let mountainName = userDefaults.climbingMountain?.name {
            return MeasurementEntry(
                date: date,
                measurementState: .measuring(mountainName: mountainName, startDate: startDate)
            )
        } else {
            return MeasurementEntry(date: date, measurementState: .idle)
        }
    }
}
