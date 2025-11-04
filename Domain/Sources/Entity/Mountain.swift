//
//  Mountain.swift
//  Domain
//
//  Created by 김영훈 on 9/27/25.
//

import Foundation
import Core

public struct Mountain: Hashable, Codable {
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

extension Mountain {
    public static func fromDTO(_ dto: MountainDTO) -> Mountain {
        return Mountain(id: dto.id, name: dto.name, address: dto.address, height: dto.height, isFamous: dto.isFamous)
    }
    
    public func toDTO() -> MountainDTO {
        return MountainDTO(id: id, name: name, address: address, height: height, isFamous: isFamous)
    }
}

extension Mountain {
    public static let dummy: [Mountain] = [
        Mountain(
            id: 1,
            name: "한라산",
            address: "제주특별자치도 제주시",
            height: 1950,
            isFamous: true
        ),
        Mountain(
            id: 2,
            name: "설악산",
            address: "강원특별자치도 속초시",
            height: 1708,
            isFamous: true
        ),
        Mountain(
            id: 3,
            name: "북한산",
            address: "서울특별시 은평구",
            height: 836,
            isFamous: true
        ),
        Mountain(
            id: 4,
            name: "지리산",
            address: "전라남도 구례군",
            height: 1915,
            isFamous: false
        ),
        Mountain(
            id: 5,
            name: "태백산",
            address: "강원도 태백시",
            height: 1567,
            isFamous: false
        ),
    ]
}
