//
//  MountainLocation.swift
//  Domain
//
//  Created by 김영훈 on 10/4/25.
//

import Foundation

public struct MountainLocation: Hashable {
    public let id: Int
    public let name: String
    public let latitude: Double
    public let longitude: Double
    public let height: Int
    public let address: String
    
    public init(id: Int, name: String, latitude: Double, longitude: Double, height: Int, address: String) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.height = height
        self.address = address
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
