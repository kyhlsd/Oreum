//
//  MountainLocationDTO.swift
//  Data
//
//  Created by 김영훈 on 10/4/25.
//

import Foundation
import Domain

struct MountainLocationDTO: Decodable {
    private let name: String
    private let latitude: Double
    private let longitude: Double
}

extension MountainLocationDTO {
    func toDomain() -> MountainLocation {
        return MountainLocation(
            name: name,
            latitude: latitude,
            longitude: longitude
        )
    }
}
