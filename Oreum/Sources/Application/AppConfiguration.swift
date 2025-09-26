//
//  AppConfiguration.swift
//  Oreum
//
//  Created by 김영훈 on 9/25/25.
//

import Foundation

struct AppConfiguration {
    
    enum Environment {
        case dev
    }
    
    let environment: Environment
    
    static let current: AppConfiguration = {
        return AppConfiguration(environment: .dev)
    }()
}
