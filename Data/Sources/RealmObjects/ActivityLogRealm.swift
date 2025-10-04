//
//  ActivityLogRealm.swift
//  Data
//
//  Created by 김영훈 on 10/3/25.
//

import Foundation
import RealmSwift
import Domain

final class ActivityLogRealm: Object {
    @Persisted(primaryKey: true) private var id: ObjectId
    @Persisted private var time: Date
    @Persisted private var step: Int
    @Persisted private var distance: Int
    @Persisted(originProperty: "timeLog") private var climbRecordRealm: LinkingObjects<ClimbRecordRealm>
}

extension ActivityLogRealm {
    func toDomain() -> ActivityLog {
        return ActivityLog(id: id.stringValue, time: time, step: step, distance: distance)
    }
    
    convenience init(from domain: ActivityLog) {
        self.init()
        self.id = (try? ObjectId(string: domain.id)) ?? ObjectId.generate()
        self.time = domain.time
        self.step = domain.step
        self.distance = domain.distance
    }
}
