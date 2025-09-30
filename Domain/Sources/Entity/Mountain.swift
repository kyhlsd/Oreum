//
//  Mountain.swift
//  Domain
//
//  Created by 김영훈 on 9/27/25.
//

import Foundation

public struct Mountain: Hashable {
    public let id: String
    public let name: String
    public let address: String
    public let height: Int
    public let isFamous: Bool
}

extension Mountain {
    public static let dummy: [Mountain] = [
        Mountain(
            id: "MT001",
            name: "한라산",
            address: "제주특별자치도 제주시",
            height: 1950,
            isFamous: true
        ),
        Mountain(
            id: "MT002",
            name: "설악산",
            address: "강원특별자치도 속초시",
            height: 1708,
            isFamous: true
        ),
        Mountain(
            id: "MT003",
            name: "북한산",
            address: "서울특별시 은평구",
            height: 836,
            isFamous: true
        ),
        Mountain(
            id: "MT004",
            name: "지리산",
            address: "전라남도 구례군",
            height: 1915,
            isFamous: false
        ),
        Mountain(
            id: "MT005",
            name: "태백산",
            address: "강원도 태백시",
            height: 1567,
            isFamous: false
        ),
    ]
}
