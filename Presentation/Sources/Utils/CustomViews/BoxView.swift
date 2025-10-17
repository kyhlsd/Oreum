//
//  BoxView.swift
//  Presentation
//
//  Created by 김영훈 on 9/28/25.
//

import UIKit
import SnapKit

final class BoxView: BaseView {
    
    // 제목 레이블
    let titleLabel = UILabel.create(color: AppColor.primaryText, font: AppFont.titleM)
    
    // 구분선
    let lineView = {
        let view = UIView()
        view.backgroundColor = AppColor.border
        return view
    }()
    
    convenience init(title: String) {
        self.init()
        configure(title)
    }
    
    func configure(_ title: String) {
        titleLabel.text = title
    }
    
    // MARK: - Setups
    
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
