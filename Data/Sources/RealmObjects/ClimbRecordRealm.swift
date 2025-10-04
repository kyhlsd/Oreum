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
    @Persisted var mountain: MountainRealm?
    @Persisted private var timeLog: List<ActivityLogRealm>
    @Persisted var images: List<RecordImageRealm>
    @Persisted private var score: Int
    @Persisted private var comment: String
    @Persisted var isBookmarked: Bool
    @Persisted private var climbDate: Date
}

extension ClimbRecordRealm {
    func toDomain() -> ClimbRecord {
        return ClimbRecord(id: id.stringValue,
                           mountain: mountain?.toDomain() ?? Mountain(id: UUID().uuidString, name: "error", address: "error", height: 0, isFamous: false),
                           timeLog: timeLog.map { $0.toDomain() },
                           images: images.map { $0.toDomain() },
                           score: score,
                           comment: comment,
                           isBookmarked: isBookmarked,
                           climbDate: climbDate)
    }

    convenience init(from domain: ClimbRecord) {
        self.init()
        self.id = (try? ObjectId(string: domain.id)) ?? ObjectId.generate()
        self.mountain = MountainRealm(from: domain.mountain)
        self.timeLog.append(objectsIn: domain.timeLog.map { ActivityLogRealm(from: $0) })
        self.images.append(objectsIn: domain.images.map { RecordImageRealm(from: $0) })
        self.score = domain.score
        self.comment = domain.comment
        self.isBookmarked = domain.isBookmarked
        self.climbDate = domain.climbDate
    }
}
