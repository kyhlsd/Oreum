//
//  UserDefaultHelper.swift
//  Data
//
//  Created by 김영훈 on 10/2/25.
//

import Foundation

enum UserDefaultHelper {
    @UserDefault(key: "ClimbingStartDate", type: TimeInterval.self)
    static var startDate: TimeInterval?
    
    static func clearStartDate() {
        startDate = nil
    }
}

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let type: T.Type
    
    var wrappedValue: T? {
        get {
            return UserDefaults.standard.object(forKey: key) as? T
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
