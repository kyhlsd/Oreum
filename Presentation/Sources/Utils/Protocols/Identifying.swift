//
//  Identifying.swift
//  Presentation
//
//  Created by 김영훈 on 9/27/25.
//

import Foundation

protocol Identifying: AnyObject {
    static var identifier: String { get }
}

extension Identifying {
    static var identifier: String {
        return String(describing: self)
    }
}
