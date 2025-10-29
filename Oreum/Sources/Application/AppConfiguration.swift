//
//  AppConfiguration.swift
//  Oreum
//
//  Created by 김영훈 on 9/25/25.
//

import Foundation
import Core

struct AppConfiguration: EnvironmentConfigurable {

    let environment: Environment

    static let current: AppConfiguration = {
        return AppConfiguration(environment: .release)
    }()
    
}
