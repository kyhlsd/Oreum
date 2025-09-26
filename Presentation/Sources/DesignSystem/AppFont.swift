//
//  AppFont.swift
//  Common
//
//  Created by 김영훈 on 9/25/25.
//

import UIKit

enum AppFont {
    // MARK: - Base
    static let baseSize: CGFloat = 16
    static let weightRegular: UIFont.Weight = .regular
    static let weightMedium: UIFont.Weight = .medium

    // MARK: - Titles
    static var titleXL: UIFont { UIFont.systemFont(ofSize: 24, weight: .medium) } // h1
    static var titleL: UIFont  { UIFont.systemFont(ofSize: 20, weight: .medium) } // h2
    static var titleM: UIFont  { UIFont.systemFont(ofSize: 18, weight: .medium) } // h3
    static var titleS: UIFont  { UIFont.systemFont(ofSize: 16, weight: .medium) } // h4

    // MARK: - Body / Text
    static var body: UIFont    { UIFont.systemFont(ofSize: 16, weight: .regular) } // p
    static var label: UIFont   { UIFont.systemFont(ofSize: 16, weight: .medium) }  // label
    static var description: UIFont { UIFont.systemFont(ofSize: 14, weight: .regular)}
    static var button: UIFont  { UIFont.systemFont(ofSize: 16, weight: .medium) }  // button
    static var input: UIFont   { UIFont.systemFont(ofSize: 16, weight: .regular) } // input
    static var tag: UIFont { UIFont.systemFont(ofSize: 12, weight: .medium) } // tag
}

