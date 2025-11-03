//
//  UserDefaultsManager.swift
//  Data
//
//  Created by 김영훈 on 10/2/25.
//

import Foundation

public final class UserDefaultsManager {
    
    public static let shared = UserDefaultsManager()
    private init() {}
    
    private static let appGroupID = "group.com.kyh.Oreum"
    
    static let userDefaults = UserDefaults(suiteName: appGroupID)
    
    public enum Key: String {
        case climbingStartDate = "ClimbingStartDate"
        case climbingMountain = "ClimbingMountain"
    }
    
    @UserDefaultBasic(key: Key.climbingStartDate.rawValue, type: TimeInterval.self)
    public var startDate: TimeInterval?

    @UserDefaultObject(key: Key.climbingMountain.rawValue, type: MountainDTO.self)
    public var climbingMountain: MountainDTO?

    public func clearStartDate() {
        startDate = nil
    }

    public func clearClimbingMountain() {
        climbingMountain = nil
    }
}

// MARK: Property Wrappers

@propertyWrapper
public struct UserDefaultBasic<T> {
    private let key: String
    private let type: T.Type
    private let userDefault = UserDefaultsManager.userDefaults
    
    public init(key: String, type: T.Type) {
        self.key = key
        self.type = type
    }
    
    public var wrappedValue: T? {
        get {
            return userDefault?.object(forKey: key) as? T
        }
        set {
            userDefault?.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
public struct UserDefaultObject<T: Codable> {
    private let key: String
    private let type: T.Type
    private let userDefault = UserDefaultsManager.userDefaults
    
    public init(key: String, type: T.Type) {
        self.key = key
        self.type = type
    }
    
    public var wrappedValue: T? {
        get {
            guard let data = userDefault?.data(forKey: key) else { return nil }
            return try? JSONDecoder().decode(T.self, from: data)
        }
        set {
            if let newValue, let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: key)
            } else {
                userDefault?.removeObject(forKey: key)
            }
        }
    }
}

