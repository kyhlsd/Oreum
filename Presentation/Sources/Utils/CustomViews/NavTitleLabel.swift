//
//  NavTitleLabel.swift
//  Presentation
//
//  Created by 김영훈 on 9/27/25.
//

import UIKit

final class NavTitleLabel: UILabel {
    
    private let title: String
    
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        textColor = AppColor.primaryText
        font = AppFont.titleL
        text = title
    }
}
