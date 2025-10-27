//
//  CustomSearchBar.swift
//  Presentation
//
//  Created by 김영훈 on 9/30/25.
//

import UIKit

final class CustomSearchBar: UISearchBar {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setBorder(_ hasBorder: Bool) {
        let color = isFirstResponder ? AppColor.focusRing : UIColor.clear
        layer.borderColor = color.cgColor
    }
    
    private func setup() {
        placeholder = "산 이름을 입력하세요"
        searchTextField.font = AppFont.input
        searchTextField.textColor = AppColor.inputText
        searchTextField.leftView?.tintColor = AppColor.mossGreen
        backgroundImage = UIImage()
        if #available(iOS 26.0, *) {
            setSearchFieldBackgroundImage(UIImage(), for: .normal)
        } else {
            searchTextField.subviews.first?.isHidden = true
        }
        layer.borderWidth = 2.0
        layer.cornerRadius = AppRadius.medium
        returnKeyType = .search
    }
    
}
