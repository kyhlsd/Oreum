//
//  MountainInfoDTO.swift
//  Data
//
//  Created by 김영훈 on 10/4/25.
//

import Foundation
import Domain

// 임시 데이터, API 복구 후 변경 예정
struct MountainInfoDTO: Decodable {
    private let MNTN_CD_INFO: String?                    // 산 코드 정보
    private let MNTN_NM: String                          // 산명
    private let MNTN_LOCPLC_REGION_NM: String            // 산 소재지 지역명
    private let HUN_LRGE_FAMMNT_SELECT_DTCONT: String?   // 100대 명산 선정 상세 내용
    private let MNTN_HG_VL: String                       // 산 높이 값(m)
    private let MNTN_MANAGE_MAINBD_INST_NM: String?      // 산 관리 주체 기관명
    private let MNTN_INFO_SUMRY_DTCONT: String?          // 산 정보 개요 상세 내용
    private let DETAIL_INFO_DTCONT: String               // 상세 정보
    private let TRNSPORT_INFO: String?                   // 교통 정보 상세 내용
    private let CIRCUMFR_TURSM_INFO_DTCONT: String?      // 주변 관광 정보 상세 내용
    private let CIRCUMFR_TURSM_INFO_IMAGE_URL: String?   // 주변 관광 정보 이미지 URL
    private let HUN_LRGE_FAMMNT_COCHNG_URL: String?      // 100대 명산 지도 URL
    private let MNTN_INFO_IMAGE_URL: String?             // 산 정보 이미지 URL
    private let MNTN_COCHNG_FILE_URL: String?            // 산 지도 파일 URL
    private let TRNSPORT_INFO_IMAGE_URL: String?         // 교통 정보 이미지 URL
    private let MNTN_SUBTL_INFO: String?                 // 산 부제 정보
    private let RECOMEND_COURSE_IMAGE_URL: String?       // 추천 코스 이미지 URL
}

extension MountainInfoDTO {
    func toDomain() -> MountainInfo {
            return MountainInfo(
                id: UUID().uuidString,                                 // 산 코드 정보
                name: MNTN_NM,                                         // 산명
                address: MNTN_LOCPLC_REGION_NM,                        // 산 소재지
                height: Int(MNTN_HG_VL) ?? 0,                                    // 산 높이
                admin: MNTN_MANAGE_MAINBD_INST_NM ?? "",               // 관리 기관명
                adminNumber: "",                                       // 관리 연락처
                detail: DETAIL_INFO_DTCONT,                            // 상세 정보
                image: MNTN_INFO_IMAGE_URL,                            // 산 이미지
                referenceDate: Date(timeIntervalSince1970: 1576108800),// 기준 날짜
                designationCriteria: HUN_LRGE_FAMMNT_SELECT_DTCONT     // 100대 명산 선정 이유
            )
        }
}
