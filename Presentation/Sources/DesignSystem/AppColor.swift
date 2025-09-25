//
//  AppColor.swift
//  Presentation
//
//  Created by 김영훈 on 9/25/25.
//

import UIKit

enum AppColor {
    // MARK: - Backgrounds
    static let background = UIColor(hex: "#fafbf8")   // 앱 배경
    static let cardBackground = UIColor(hex: "#ffffff")
    static let popoverBackground = UIColor(hex: "#ffffff")
    static let sidebarBackground = UIColor(hex: "#f8faf9")
    
    // MARK: - Text
    static let primaryText = UIColor(hex: "#1a2319")   // 메인 텍스트
    static let cardText = UIColor(hex: "#1a2319")
    static let popoverText = UIColor(hex: "#1a2319")
    static let sidebarText = UIColor(hex: "#1a2319")
    
    // MARK: - Buttons
    static let primary = UIColor(hex: "#2d5832")           // 주요 버튼 배경
    static let primaryForeground = UIColor(hex: "#ffffff") // 주요 버튼 텍스트
    static let secondary = UIColor(hex: "#e8f3ea")         // 보조 버튼 배경
    static let secondaryForeground = UIColor(hex: "#1a2319") // 보조 버튼 텍스트
    
    // MARK: - States
    static let disabledBackground = UIColor(hex: "#f1f5f2")
    static let disabledText = UIColor(hex: "#5a6b5d")
    static let accent = UIColor(hex: "#d4e5d7")
    static let accentText = UIColor(hex: "#1a2319")
    static let danger = UIColor(hex: "#dc2626")
    static let dangerText = UIColor(hex: "#ffffff")
    
    // MARK: - Form & Border
    static let border = UIColor(hex: "#2d5832").withAlphaComponent(0.15)
    static let inputBackground = UIColor(hex: "#f8faf9")
    static let switchBackground = UIColor(hex: "#cbd5ce")
    static let focusRing = UIColor(hex: "#2d5832")
    
    // MARK: - Chart
    static let chart1 = UIColor(hex: "#2d5832")
    static let chart2 = UIColor(hex: "#4a7c59")
    static let chart3 = UIColor(hex: "#6ba16e")
    static let chart4 = UIColor(hex: "#8ec691")
    static let chart5 = UIColor(hex: "#b3d9b6")
    
    // MARK: - Sidebar
    static let sidebarPrimary = UIColor(hex: "#2d5832")
    static let sidebarPrimaryText = UIColor(hex: "#ffffff")
    static let sidebarAccent = UIColor(hex: "#e8f3ea")
    static let sidebarAccentText = UIColor(hex: "#1a2319")
    static let sidebarBorder = UIColor(hex: "#2d5832").withAlphaComponent(0.15)
    static let sidebarFocusRing = UIColor(hex: "#2d5832")
    
    // MARK: - Nature Colors
    static let forestGreen = UIColor(hex: "#2d5832")
    static let mossGreen = UIColor(hex: "#4a7c59")
    static let sageGreen = UIColor(hex: "#6ba16e")
    static let earthBrown = UIColor(hex: "#8b5a3c")
    static let skyBlue = UIColor(hex: "#4a90a4")
    static let stoneGray = UIColor(hex: "#7a8471")
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
