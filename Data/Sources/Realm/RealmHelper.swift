//
//  RealmHelper.swift
//  Data
//
//  Created by 김영훈 on 10/25/25.
//

import Foundation
import RealmSwift

public enum RealmHelper {

    public static let shared: Realm? = {
        configure()
        let realm = try? Realm()
        print(realm?.configuration.fileURL ?? "realm initialization failed")
        return realm
    }()

    private static func configure() {
        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    // 버전 0 -> 1: MountainRealm primary key 타입 변경 (ObjectId -> Int)
                    var nextNegativeId = -1

                    migration.enumerateObjects(ofType: MountainRealm.className()) { oldObject, newObject in
                        guard let oldObject = oldObject, let newObject = newObject else { return }

                        // 음수 ID 할당 (기존 로컬 데이터)
                        newObject["id"] = nextNegativeId
                        newObject["name"] = oldObject["name"]
                        newObject["address"] = oldObject["address"]
                        newObject["height"] = oldObject["height"]
                        newObject["isFamous"] = oldObject["isFamous"]

                        nextNegativeId -= 1
                    }
                }
            }
        )

        Realm.Configuration.defaultConfiguration = config
    }

}
