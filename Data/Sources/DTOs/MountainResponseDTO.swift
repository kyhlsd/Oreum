//
//  MountainResponseDTO.swift
//  Data
//
//  Created by 김영훈 on 10/4/25.
//

import Foundation
import Domain

struct MountainResponseDTO: Decodable, Sendable {
    fileprivate let header: HeaderDTO
    fileprivate let body: BodyDTO
}

fileprivate struct HeaderDTO: Decodable {
    let resultCode: String
    let resultMsg: String
}

fileprivate struct BodyDTO: Decodable {
    let items: MountainItemsDTO
    let numOfRows: String
    let pageNo: String
    let totalCount: String
}

fileprivate struct MountainItemsDTO: Decodable {
    let item: [MountainInfoDTO]
}

fileprivate struct MountainInfoDTO: Decodable {
    private let mntiadd: String // 주소
    private let mntiadmin: String // 관리 주체 기관명
    private let mntiadminnum: String // 전화번호
    private let mntidetails: String // 산 정보
    private let mntihigh: String // 산 높이
    private let mntilistno: String // 산 고유 번호
    private let mntiname: String // 산 이름
    private let mntinfdt: String // 기록 날짜
    private let mntisname: String // 산 부제
    private let mntisummary: String // 산 요약
    private let mntitop: String // 명산 선정 이유
}

extension HeaderDTO {
    func toDomain() -> MountainResponse.Header {
        return MountainResponse.Header(resultCode: resultCode, resultMessage: resultMsg)
    }
}

extension BodyDTO {
    func toDomain() -> MountainResponse.Body {
        return MountainResponse.Body(items: items.toDomain(), numOfRows: Int(numOfRows) ?? -1, page: Int(pageNo) ?? -1, totalCount: Int(totalCount) ?? -1 )
    }
}

extension MountainItemsDTO {
    func toDomain() -> MountainResponse.Body.Items {
        return MountainResponse.Body.Items(item: item.map { $0.toDomain() })
    }
}

extension MountainInfoDTO {
    func toDomain() -> MountainInfo {
        var height: Int?
        if mntihigh != "0", let double = Double(mntihigh) {
            height = Int(double)
        }
        return MountainInfo(id: Int(mntilistno) ?? -1, name: mntiname, address: mntiadd, height: height, admin: mntiadmin, adminNumber: mntiadminnum, detail: mntidetails, referenceDate: Self.formatter.date(from: mntinfdt), designationCriteria: mntitop.isEmpty ? nil : mntitop)
    }
    
    static let formatter = {
       let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        return formatter
    }()
}

extension MountainResponseDTO {
    func toDomain() -> MountainResponse {
        MountainResponse(header: header.toDomain(), body: body.toDomain())
    }
}
