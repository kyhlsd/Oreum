//
//  MountainLocationDTO.swift
//  Data
//
//  Created by 김영훈 on 10/4/25.
//

import Foundation
import Domain

struct MountainLocationDTO: Decodable {
    private let id: Int
    private let name: String
    private let latitude: Double
    private let longitude: Double
    private let height: Int
    private let address: String
}

extension MountainLocationDTO {
    func toDomain() -> MountainLocation {
        return MountainLocation(
            id: id,
            name: name,
            latitude: latitude,
            longitude: longitude,
            height: height,
            address: address
        )
    }
}
