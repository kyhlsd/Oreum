//
//  BaseView.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit

class BaseView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupHierarchy()
        setupLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {}
    func setupHierarchy() {}
    func setupLayout() {}
    
}
