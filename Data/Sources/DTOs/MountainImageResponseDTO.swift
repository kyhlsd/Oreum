//
//  MountainImageResponseDTO.swift
//  Data
//
//  Created by 김영훈 on 10/24/25.
//

import Foundation

struct MountainImageResponseDTO: Decodable, Sendable {
    fileprivate let header: HeaderDTO
    fileprivate let body: BodyDTO
}

fileprivate struct HeaderDTO: Decodable {
    let resultCode: String
    let resultMsg: String
}

fileprivate struct BodyDTO: Decodable {
    let items: MountainImageItemsDTO
    let numOfRows: String
    let pageNo: String
    let totalCount: String
}

fileprivate struct MountainImageItemsDTO: Decodable {
    let item: [MountainImageDTO]
}

fileprivate struct MountainImageDTO: Decodable {
    let imgfilename: String
    let imgname: String
    let imgno: String
}

extension MountainImageResponseDTO {
    func toURL() -> [URL] {
        return body.items.item.compactMap {
            URL(string: APIInfos.MountainImage.baseURL + $0.imgfilename)
        }
    }
}
