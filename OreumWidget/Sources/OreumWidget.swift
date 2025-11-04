//
//  OreumWidget.swift
//  OreumWidget
//
//  Created by 김영훈 on 11/4/25.
//

import WidgetKit
import SwiftUI
import Core

@main
struct OreumWidgetBundle: WidgetBundle {
    var body: some Widget {
        OreumWidget()
    }
}

struct OreumWidget: Widget {
    let kind = "OreumWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                OreumWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                OreumWidgetEntryView(entry: entry)
                    .background(.tertiary)
            }
        }
        .configurationDisplayName("오름")
        .description("등산 측정 현황을 확인하세요")
        .supportedFamilies([.systemSmall])
    }
}
