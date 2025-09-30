//
//  CustomButton.swift
//  Presentation
//
//  Created by 김영훈 on 9/28/25.
//

import UIKit

final class CustomButton: UIButton {
    
    init(title: String, image: UIImage?, foreground: UIColor, background: UIColor, hasBorder: Bool = false) {
        super.init(frame: .zero)
        setup(title: title, image: image, foreground: foreground, background: background, hasBorder: hasBorder)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup(title: String, image: UIImage?, foreground: UIColor, background: UIColor, hasBorder: Bool) {
        var config = UIButton.Configuration.plain()
        config.image = image?.applyingSymbolConfiguration(.init(pointSize: 12))
        config.imagePadding = AppSpacing.small
        config.baseForegroundColor = foreground
        config.attributedTitle = AttributedString(title, attributes: AttributeContainer([.font: AppFont.button]))
        configuration = config
        backgroundColor = background
        layer.cornerRadius = AppRadius.radius
        
        if hasBorder {
            layer.borderColor = foreground.cgColor
            layer.borderWidth = 1.0
        }
    }
}
