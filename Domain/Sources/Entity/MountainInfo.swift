//
//  MountainInfo.swift
//  Domain
//
//  Created by 김영훈 on 9/30/25.
//

import Foundation

public struct MountainInfo: Hashable {
    public let id: String
    public let name: String
    public let address: String

    public init(id: String, name: String, address: String) {
        self.id = id
        self.name = name
        self.address = address
    }
}

extension MountainInfo {
    public static let dummy = [
        MountainInfo(id: "1", name: "북한산", address: "서울특별시 서대문구 홍은동"),
        MountainInfo(id: "2", name: "북한산_백운대", address: "서울특별시 강북구 우이동"),
        MountainInfo(id: "3", name: "한라산", address: "제주특별자치도"),
        MountainInfo(id: "4", name: "설악산", address: "강원도 속초시"),
        MountainInfo(id: "5", name: "지리산", address: "전라남도/경상남도"),
        MountainInfo(id: "6", name: "관악산", address: "서울특별시 관악구"),
        MountainInfo(id: "7", name: "도봉산", address: "서울특별시 도봉구"),
        MountainInfo(id: "8", name: "인왕산", address: "서울특별시 종로구"),
        MountainInfo(id: "9", name: "청계산", address: "경기도 성남시"),
        MountainInfo(id: "10", name: "남산", address: "서울특별시 용산구")
    ]
}
