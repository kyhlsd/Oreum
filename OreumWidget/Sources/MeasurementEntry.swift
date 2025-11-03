//
//  MeasurementEntry.swift
//  OreumWidget
//
//  Created by 김영훈 on 11/4/25.
//

import WidgetKit
import Foundation

struct MeasurementEntry: TimelineEntry {
    let date: Date
    let measurementState: MeasurementState
}

enum MeasurementState {
    case measuring(mountainName: String, startDate: TimeInterval)
    case idle
    case placeholder

    var isMeasuring: Bool {
        switch self {
        case .measuring:
            return true
        case .idle, .placeholder:
            return false
        }
    }
}
