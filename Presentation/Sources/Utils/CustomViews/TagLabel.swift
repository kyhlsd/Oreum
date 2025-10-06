//
//  TagLabel.swift
//  Presentation
//
//  Created by 김영훈 on 10/5/25.
//

import UIKit

final class TagLabel: PaddingLabel {
    
    init(text: String, textColor: UIColor, backgroundColor: UIColor) {
        super.init(padding: UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6))
        setup(text: text, textColor: textColor, backgroundColor: backgroundColor)
    }
    
    private func setup(text: String, textColor: UIColor, backgroundColor: UIColor) {
        self.text = text
        font = AppFont.tag
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        layer.cornerRadius = AppRadius.radius
        clipsToBounds = true
    }
}
