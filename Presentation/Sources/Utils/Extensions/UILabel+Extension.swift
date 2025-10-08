//
//  UILabel+Extension.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit

extension UILabel {
    
    static func create(_ text: String? = nil, color: UIColor, font: UIFont) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = color
        label.font = font
        return label
    }
    
}
