//
//  AppFont.swift
//  Common
//
//  Created by 김영훈 on 9/25/25.
//

import UIKit

enum AppFont {
    // MARK: - Titles
    static var titleL: UIFont  { UIFont.systemFont(ofSize: 20, weight: .medium) }
    static var titleM: UIFont  { UIFont.systemFont(ofSize: 16, weight: .medium) }
    static var titleS: UIFont  { UIFont.systemFont(ofSize: 14, weight: .medium) }

    // MARK: - Body / Text
    static var body: UIFont    { UIFont.systemFont(ofSize: 14, weight: .regular) }
    static var description: UIFont { UIFont.systemFont(ofSize: 12, weight: .regular)}
    static var input: UIFont   { UIFont.systemFont(ofSize: 16, weight: .regular) }
    static var tag: UIFont { UIFont.systemFont(ofSize: 12, weight: .medium) }
}

