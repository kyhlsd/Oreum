//
//  BoxView.swift
//  Presentation
//
//  Created by 김영훈 on 9/28/25.
//

import UIKit
import SnapKit

final class BoxView: BaseView {
    
    let titleLabel = UILabel.create(color: AppColor.primaryText, font: AppFont.titleM)
    
    let lineView = {
        let view = UIView()
        view.backgroundColor = AppColor.border
        return view
    }()
    
    convenience init(title: String) {
        self.init()
        configure(title: title)
    }
    
    func configure(title: String) {
        titleLabel.text = title
    }

    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    override func setupView() {
        layer.borderColor = AppColor.border.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = AppRadius.radius
        backgroundColor = AppColor.boxBackground
    }
    
    override func setupHierarchy() {
        [titleLabel, lineView].forEach {
            addSubview($0)
        }
    }
    
    override func setupLayout() {
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(AppSpacing.compact)
        }
        
        lineView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(AppSpacing.compact)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(1.0)
        }
    }
}
