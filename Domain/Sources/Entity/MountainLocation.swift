//
//  MountainLocation.swift
//  Domain
//
//  Created by 김영훈 on 10/4/25.
//

import Foundation

public struct MountainLocation: Hashable {
    public let name: String
    public let latitude: Double
    public let longitude: Double
    
    public init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}

public struct MountainDistance: Hashable {
    public let mountainLocation: MountainLocation
    public let distance: Double
    
    public init(mountainLocation: MountainLocation, distance: Double) {
        self.mountainLocation = mountainLocation
        self.distance = distance
    }
}
