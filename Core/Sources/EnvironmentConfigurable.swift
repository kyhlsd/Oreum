//
//  EnvironmentConfigurable.swift
//  Core
//
//  Created by 김영훈 on 10/8/25.
//

import Foundation

public enum Environment {
    case release
    case dev
    case dummy
}

public protocol EnvironmentConfigurable {
    var environment: Environment { get }
}
