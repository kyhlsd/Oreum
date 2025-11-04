//
//  MountainDTO.swift
//  Core
//
//  Created by 김영훈 on 11/4/25.
//

import Foundation

public struct MountainDTO: Hashable, Codable {
    public let id: Int
    public let name: String
    public let address: String
    public let height: Int?
    public let isFamous: Bool

    public init(id: Int, name: String, address: String, height: Int?, isFamous: Bool) {
        self.id = id
        self.name = name
        self.address = address
        self.height = height
        self.isFamous = isFamous
    }
}
