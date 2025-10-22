//
//  AppAppearance.swift
//  Oreum
//
//  Created by 김영훈 on 9/25/25.
//

import UIKit

public enum AppAppearance {
    
    // NavigationBar 설정
    public static func setupNavAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.backgroundColor = .clear
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    public static func getMainTitle(title: String) -> AttributedString {
        return AttributedString(title, attributes: AttributeContainer([
            .foregroundColor: AppColor.primaryText,
            .font: AppFont.titleL
        ]))
    }
    
    // TabBar 설정
    public static func setupTabAppearance() {
        let appearance = UITabBarAppearance()
        appearance.stackedLayoutAppearance.selected.iconColor = AppColor.tabSelectedForeground
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: AppColor.tabSelectedForeground]
        appearance.stackedLayoutAppearance.normal.iconColor = AppColor.tabNormal
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: AppColor.tabNormal]
        appearance.backgroundColor = AppColor.tabBarBackground
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
}
