//
//  MountainRealm.swift
//  Data
//
//  Created by 김영훈 on 10/3/25.
//

import Foundation
import RealmSwift
import Domain

final class MountainRealm: Object {
    @Persisted(primaryKey: true) private var id: ObjectId
    @Persisted private var name: String
    @Persisted private var address: String
    @Persisted private var height: Int
    @Persisted private var isFamous: Bool
}

extension MountainRealm {
    func toDomain() -> Mountain {
        return Mountain(id: id.stringValue, name: name, address: address, height: height, isFamous: isFamous)
    }
    
    convenience init(from domain: Mountain) {
        self.init()
        self.id = (try? ObjectId(string: domain.id)) ?? ObjectId.generate()
        self.name = domain.name
        self.address = domain.address
        self.height = domain.height
        self.isFamous = domain.isFamous
    }
}
