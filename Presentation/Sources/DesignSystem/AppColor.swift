//
//  AppColor.swift
//  Presentation
//
//  Created by 김영훈 on 9/25/25.
//

import UIKit

enum AppColor {
    // MARK: - Backgrounds
    static let background = UIColor(hex: "#fafbf8")
    static let boxBackground = UIColor(hex: "#ffffff")
    static let tabBarBackground = UIColor(hex: "#ffffff")
    static let cardBackground = UIColor(hex: "#e8f3ea").withAlphaComponent(0.7)

    // MARK: - Text
    static let primaryText = UIColor(hex: "#1a2319")
    static let tertiaryText = UIColor(hex: "B0B0B0")
    static let inputText = UIColor(hex: "#1a2319")
    static let subText = UIColor(hex: "#5a6b5d")

    // MARK: - Buttons
    static let primary = Self.forestGreen
    static let secondary = UIColor(hex: "#e8f3ea")

    // MARK: - States
    static let danger = UIColor(hex: "#dc2626")
    static let dangerText = UIColor(hex: "#ffffff")

    // MARK: - Form & Border
    static let border = Self.forestGreen.withAlphaComponent(0.15)
    static let focusRing = Self.forestGreen

    //MARK: - TabBar
    static let tabSelectedForeground = Self.forestGreen
    static let tabNormal = UIColor(hex: "#7a8471")

    //MARK: - TagLabel
    static let firstVisitForeground = UIColor(hex: "#92400e")
    static let firstVisitBackground = UIColor(hex: "#fef3c7")
    static let famousForeground = UIColor(hex: "#065f46")
    static let famousBackground = UIColor(hex: "#d1fae5")
    static let distanceForground = UIColor(hex: "#dc2626")
    static let distanceBackground = UIColor(hex: "#fef2f2")

    // MARK: - Nature Colors
    static let forestGreen = UIColor(hex: "#2d5832")
    static let mossGreen = UIColor(hex: "#4a7c59")
}

// MARK: - UIColor Hex Init
extension UIColor {
    convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexString.hasPrefix("#") { hexString.removeFirst() }
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        if hexString.count == 6 {
            self.init(
                red: CGFloat((rgbValue & 0xFF0000) >> 16)/255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8)/255.0,
                blue: CGFloat(rgbValue & 0x0000FF)/255.0,
                alpha: 1.0
            )
        } else {
            self.init(white: 0.0, alpha: 1.0)
        }
    }
}
