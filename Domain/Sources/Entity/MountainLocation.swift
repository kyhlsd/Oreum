//
//  MountainLocation.swift
//  Domain
//
//  Created by 김영훈 on 10/4/25.
//

import Foundation

public struct MountainLocation {
    let name: String
    let latitude: Double
    let longitude: Double
    
    public init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}
