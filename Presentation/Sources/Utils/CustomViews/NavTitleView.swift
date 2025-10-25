//
//  NavTitleView.swift
//  Presentation
//
//  Created by 김영훈 on 10/23/25.
//

import UIKit
import SnapKit

final class NavTitleView: BaseView {
    
    private let titleLabel: NavTitleLabel
    
    init(title: String) {
        self.titleLabel = NavTitleLabel(title: title)
        super.init(frame: .zero)
    }
    
    override func setupHierarchy() {
        addSubview(titleLabel)
    }
    
    override func setupLayout() {
        titleLabel.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }
    }
    
}
