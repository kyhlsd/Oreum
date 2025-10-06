//
//  RecentSearch.swift
//  Domain
//
//  Created by 김영훈 on 10/6/25.
//

import Foundation

public struct RecentSearch: Hashable {
    public let keyword: String
    public let searchedAt: Date

    public init(keyword: String, searchedAt: Date) {
        self.keyword = keyword
        self.searchedAt = searchedAt
    }
}
