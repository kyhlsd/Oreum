//
//  OreumWidgetEntryView.swift
//  OreumWidget
//
//  Created by 김영훈 on 11/4/25.
//

import SwiftUI
import WidgetKit

struct OreumWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        switch entry.measurementState {
        case .measuring(let mountainName, let startDate):
            MeasuringView(mountainName: mountainName, startDate: startDate, family: family)
        case .idle:
            IdleView(family: family)
        case .placeholder:
            PlaceholderView(family: family)
        }
    }
}

// MARK: - Measuring View (측정 중)
struct MeasuringView: View {
    let mountainName: String
    let startDate: TimeInterval
    let family: WidgetFamily

    private var elapsedTime: String {
        let interval = Date().timeIntervalSince1970 - startDate
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60
        let seconds = Int(interval) % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    var body: some View {
        VStack(spacing: family == .systemSmall ? 8 : 12) {
            HStack {
                Image(systemName: "figure.hiking")
                    .font(.system(size: family == .systemSmall ? 16 : 20))
                    .foregroundColor(.white)
                Text("등산 중")
                    .font(.system(size: family == .systemSmall ? 14 : 16, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(mountainName)
                    .font(.system(size: family == .systemSmall ? 18 : 22, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(elapsedTime)
                    .font(.system(size: family == .systemSmall ? 28 : 36, weight: .bold))
                    .foregroundColor(.white)
                    .monospacedDigit()
            }
            
            Spacer()
        }
        .padding(family == .systemSmall ? 16 : 20)
    }
}

// MARK: - Idle View (측정 유도)
struct IdleView: View {
    let family: WidgetFamily

    var body: some View {
        VStack(spacing: family == .systemSmall ? 12 : 16) {
            Image(systemName: "mountain.2.fill")
                .font(.system(size: family == .systemSmall ? 40 : 50))
                .foregroundColor(Color(red: 0.25, green: 0.52, blue: 0.31))
            
            VStack(spacing: 4) {
                Text("등산을 시작하세요")
                    .font(.system(size: family == .systemSmall ? 14 : 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                if family != .systemSmall {
                    Text("앱에서 측정을 시작해보세요")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(family == .systemSmall ? 16 : 20)
    }
}

// MARK: - Placeholder View
struct PlaceholderView: View {
    let family: WidgetFamily

    var body: some View {
        VStack(spacing: family == .systemSmall ? 12 : 16) {
            Image(systemName: "mountain.2.fill")
                .font(.system(size: family == .systemSmall ? 40 : 50))
                .foregroundColor(.gray.opacity(0.3))
            
            Text("오름")
                .font(.system(size: family == .systemSmall ? 14 : 16, weight: .semibold))
                .foregroundColor(.gray)
        }
        .padding(family == .systemSmall ? 16 : 20)
    }
}
