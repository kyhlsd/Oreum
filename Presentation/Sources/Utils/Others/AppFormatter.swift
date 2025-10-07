//
//  AppFormatter.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import Foundation

enum AppFormatter {
    
    static let dateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 M월 d일"
        return formatter
    }()
    
    static let timeFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    static let weekdayFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d E"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
    
}
