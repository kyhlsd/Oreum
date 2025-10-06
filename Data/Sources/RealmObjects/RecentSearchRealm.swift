//
//  RecentSearchRealm.swift
//  Data
//
//  Created by 김영훈 on 10/6/25.
//

import Foundation
import RealmSwift
import Domain

final class RecentSearchRealm: Object {
    @Persisted(primaryKey: true) private var keyword: String
    @Persisted private var searchedAt: Date
}

extension RecentSearchRealm {
    func toDomain() -> RecentSearch {
        return RecentSearch(keyword: keyword, searchedAt: searchedAt)
    }

    convenience init(keyword: String, searchedAt: Date) {
        self.init()
        self.keyword = keyword
        self.searchedAt = searchedAt
    }
}
