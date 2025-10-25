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
    @Persisted(primaryKey: true) var id: Int
    @Persisted var name: String
    @Persisted private var address: String
    @Persisted private var height: Int?
    @Persisted private var isFamous: Bool
}

extension MountainRealm {
    func toDomain() -> Mountain {
        return Mountain(id: id, name: name, address: address, height: height, isFamous: isFamous)
    }
    
    convenience init(from domain: Mountain) {
        self.init()
        self.id = domain.id
        self.name = domain.name
        self.address = domain.address
        self.height = domain.height
        self.isFamous = domain.isFamous
    }
}
