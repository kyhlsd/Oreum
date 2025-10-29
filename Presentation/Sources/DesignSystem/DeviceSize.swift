//
//  DeviceSize.swift
//  Presentation
//
//  Created by 김영훈 on 10/5/25.
//

import UIKit

// SceneDelegate에서 값 설정
public enum DeviceSize {
    
    public static var width: CGFloat = 0
    public static var height: CGFloat = 0
    public static var scale: CGFloat = 0
    
    public static func setup(_ screen: UIScreen) {
        Self.width = screen.bounds.width
        Self.height = screen.bounds.height
        Self.scale = screen.scale
    }
    
}
