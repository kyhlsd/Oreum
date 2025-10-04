//
//  RecordImageRealm.swift
//  Data
//
//  Created by 김영훈 on 10/3/25.
//

import Foundation
import RealmSwift
import Domain

final class RecordImageRealm: Object {
    @Persisted(primaryKey: true) private var id: ObjectId
    @Persisted(originProperty: "images") private var climbRecordRealm: LinkingObjects<ClimbRecordRealm>
}

extension RecordImageRealm {
    func toDomain() -> String {
        return id.stringValue
    }
    
    convenience init(from domain: String) {
        self.init()
        self.id = (try? ObjectId(string: domain)) ?? ObjectId.generate()
    }
}
