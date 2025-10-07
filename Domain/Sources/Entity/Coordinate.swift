//
//  Coordinate.swift
//  Domain
//
//  Created by 김영훈 on 10/6/25.
//

import Foundation

public struct Coordinate {
    public let longitude: Double
    public let latitude: Double
    
    public init(longitude: Double, latitude: Double) {
        self.longitude = longitude
        self.latitude = latitude
    }
}
