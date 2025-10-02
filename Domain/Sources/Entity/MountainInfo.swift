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
    public let height: Int
    public let admin: String
    public let adminNumber: String
    public let detail: String
    public let referenceDate: Date
    public let designationCriteria: String?
    
    public init(id: String, name: String, address: String, height: Int, admin: String, adminNumber: String, detail: String, referenceDate: Date, designationCriteria: String?) {
        self.id = id
        self.name = name
        self.address = address
        self.height = height
        self.admin = admin
        self.adminNumber = adminNumber
        self.detail = detail
        self.referenceDate = referenceDate
        self.designationCriteria = designationCriteria
    }
}

extension MountainInfo {
    public func toMountain(_ mountainInfo: Self) -> Mountain {
        return Mountain(id: id, name: name, address: address, height: height, isFamous: designationCriteria != nil)
    }
}

extension MountainInfo {
    public static let dummy = [
        MountainInfo(
            id: "001",
            name: "북한산",
            address: "서울특별시 강북구 우이동",
            height: 835,
            admin: "강북구청",
            adminNumber: "02-901-6114",
            detail: "서울의 진산으로 불리며 백운대, 인수봉, 만경대 등 주요 봉우리가 있음.",
            referenceDate: Date(),
            designationCriteria: "백운대, 인수봉, 만경대 등 세 봉우리와 뛰어난 자연경관"
        ),
        MountainInfo(
            id: "002",
            name: "도봉산",
            address: "서울특별시 도봉구 도봉동",
            height: 740,
            admin: "도봉구청",
            adminNumber: "02-2091-2300",
            detail: "북한산 국립공원의 일부로 수많은 암봉과 절경을 자랑한다.",
            referenceDate: Date(),
            designationCriteria: "암릉과 절경, 다양한 탐방로와 역사적 사찰"
        ),
        MountainInfo(
            id: "003",
            name: "관악산",
            address: "서울특별시 관악구 신림동",
            height: 632,
            admin: "관악구청",
            adminNumber: "02-879-5000",
            detail: "서울 남쪽을 대표하는 산으로 연주대와 삼성산 등 다양한 탐방로가 있다.",
            referenceDate: Date(),
            designationCriteria: "도심과 가까우며 역사적·문화적 가치가 높은 산"
        ),
        MountainInfo(
            id: "004",
            name: "북악산",
            address: "서울특별시 종로구 청운동",
            height: 342,
            admin: "종로구청",
            adminNumber: "02-2148-1114",
            detail: "청와대 북쪽에 위치하며 성곽길 산책로로 유명하다.",
            referenceDate: Date(),
            designationCriteria: "서울 도심과 가까운 성곽길과 전망"
        ),
        MountainInfo(
            id: "005",
            name: "인왕산",
            address: "서울특별시 종로구 무악동",
            height: 338,
            admin: "종로구청",
            adminNumber: "02-2148-2832",
            detail: "도심과 가까운 산으로 기암괴석과 서울 전경을 감상할 수 있다.",
            referenceDate: Date(),
            designationCriteria: "기암괴석과 서울 전경 감상이 가능한 명소"
        ),
        MountainInfo(
            id: "006",
            name: "청계산",
            address: "서울특별시 서초구 원지동",
            height: 618,
            admin: "서초구청",
            adminNumber: "02-2155-6114",
            detail: "서울과 성남에 걸쳐 있으며 원터골과 옛골이 대표적인 입구.",
            referenceDate: Date(),
            designationCriteria: "서울과 경기 사이 위치, 시민들의 휴식처"
        ),
        MountainInfo(
            id: "007",
            name: "수락산",
            address: "서울특별시 노원구 상계동",
            height: 638,
            admin: "노원구청",
            adminNumber: "02-2116-3114",
            detail: "암릉이 많으며 도심 속에서 짧은 산행을 즐기기 좋다.",
            referenceDate: Date(),
            designationCriteria: "바위 암릉과 접근성이 뛰어난 도심 명산"
        ),
        MountainInfo(
            id: "008",
            name: "아차산",
            address: "서울특별시 광진구 구의동",
            height: 287,
            admin: "광진구청",
            adminNumber: "02-450-1114",
            detail: "서울 동쪽 한강을 끼고 있는 산으로 가벼운 산책 코스로 인기가 많다.",
            referenceDate: Date(),
            designationCriteria: "한강 조망이 뛰어나고 가벼운 등산 가능"
        ),
        MountainInfo(
            id: "009",
            name: "불암산",
            address: "서울특별시 노원구 중계동",
            height: 508,
            admin: "노원구청",
            adminNumber: "02-2116-3333",
            detail: "수락산과 마주 보고 있으며 암릉 산행으로 유명하다.",
            referenceDate: Date(),
            designationCriteria: "암릉 산행의 명소이자 도심 속 산"
        ),
        MountainInfo(
            id: "010",
            name: "용마산",
            address: "서울특별시 중랑구 면목동",
            height: 348,
            admin: "중랑구청",
            adminNumber: "02-2094-0114",
            detail: "서울 동북부에 위치해 있으며 산세가 완만하고 가족 산행에 적합하다.",
            referenceDate: Date(),
            designationCriteria: "완만한 산세로 가족 등산에 적합"
        )
    ]
}
