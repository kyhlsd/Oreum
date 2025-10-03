//
//  ClimbRecordRealm.swift
//  Data
//
//  Created by 김영훈 on 10/3/25.
//

import Foundation
import RealmSwift
import Domain

final class ClimbRecordRealm: Object {
    @Persisted(primaryKey: true) private var id: ObjectId
    @Persisted private var mountain: MountainRealm?
    @Persisted private var timeLog: List<ActivityLogRealm>
    @Persisted private var images: List<RecordImageRealm>
    @Persisted private var score: Int
    @Persisted private var comment: String
    @Persisted private var isBookmarked: Bool
}

extension ClimbRecordRealm {
    func toDomain() -> ClimbRecord {
        return ClimbRecord(id: id.stringValue,
                           mountain: mountain?.toDomain() ?? Mountain(id: UUID().uuidString, name: "error", address: "error", height: 0, isFamous: false),
                           timeLog: timeLog.map { $0.toDomain() },
                           images: images.map { $0.toDomain() },
                           score: score,
                           comment: comment,
                           isBookmarked: isBookmarked)
    }
}
