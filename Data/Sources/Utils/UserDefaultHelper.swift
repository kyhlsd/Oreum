//
//  UserDefaultHelper.swift
//  Data
//
//  Created by 김영훈 on 10/2/25.
//

import Foundation
import Domain

enum UserDefaultHelper {
    @UserDefaultBasic(key: "ClimbingStartDate", type: TimeInterval.self)
    static var startDate: TimeInterval?

    @UserDefaultObject(key: "ClimbingMountain", type: Mountain.self)
    static var climbingMountain: Mountain?

    static func clearStartDate() {
        startDate = nil
    }

    static func clearClimbingMountain() {
        climbingMountain = nil
    }
}

@propertyWrapper
struct UserDefaultBasic<T> {
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

@propertyWrapper
struct UserDefaultObject<T: Codable> {
    let key: String
    let type: T.Type
    
    var wrappedValue: T? {
        get {
            guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
            return try? JSONDecoder().decode(T.self, from: data)
        }
        set {
            if let newValue, let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: key)
            } else {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }
}
