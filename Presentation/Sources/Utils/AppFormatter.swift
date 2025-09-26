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
        // ex) 24년 9월 2일
        formatter.dateFormat = "yy년 M월 d일"
        return formatter
    }()
    
}
