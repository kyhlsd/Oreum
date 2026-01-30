//
//  ImageItem.swift
//  Domain
//
//  Created by 김영훈 on 1/31/26.
//

import Foundation

public struct ImageItem: Hashable {
    let id = UUID()
    public let data: Data
    
    public init(data: Data) {
        self.data = data
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: ImageItem, rhs: ImageItem) -> Bool {
        return lhs.id == rhs.id
    }
}
