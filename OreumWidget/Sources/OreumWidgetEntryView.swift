//
//  OreumWidgetEntryView.swift
//  OreumWidget
//
//  Created by 김영훈 on 11/4/25.
//

import SwiftUI
import WidgetKit

struct OreumWidgetEntryView: View {

    var entry: Provider.Entry

    var body: some View {
        switch entry.measurementState {
        case .measuring(let mountainName, let startDate):
            MeasuringView(mountainName: mountainName, startDate: startDate, currentDate: entry.date)
        case .idle:
            IdleView()
        case .placeholder:
            PlaceholderView()
        }
    }
}

// MARK: - Measuring View (측정 중)
struct MeasuringView: View {
    let mountainName: String
    let startDate: TimeInterval
    let currentDate: Date
    private let primaryColor = Color.init(red: 45/225, green: 88/225, blue: 50/255)

    private var elapsedTime: String {
        let interval = currentDate.timeIntervalSince1970 - startDate
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60

        if hours > 0 {
            return "\(hours)시간 \(minutes)분"
        } else {
            return "\(minutes)분"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Spacer()
            
            HStack {
                Image(systemName: "figure.hiking")
                    .font(.system(size: 16))
                Text("등산 중")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(primaryColor)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(mountainName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Text(elapsedTime)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                    .monospacedDigit()
            }
            
            Spacer()
        }
    }
}

// MARK: - Idle View (측정 유도)
struct IdleView: View {
    private let primaryColor = Color.init(red: 45/225, green: 88/225, blue: 50/255)
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "mountain.2.fill")
                .font(.system(size: 40))
                .foregroundColor(primaryColor)
            
            VStack(spacing: 4) {
                Text("등산을 시작하세요")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("앱에서 측정을 시작해보세요")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Placeholder View
struct PlaceholderView: View {
    private let mountainName: String = "북한산"
    private let primaryColor = Color.init(red: 45/225, green: 88/225, blue: 50/255)
    private let elapsedTime: String = "1시간 17분"

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Spacer()
            
            HStack {
                Image(systemName: "figure.hiking")
                    .font(.system(size: 16))
                Text("등산 중")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(primaryColor)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(mountainName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Text(elapsedTime)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
                    .monospacedDigit()
            }
            
            Spacer()
        }
    }
}
