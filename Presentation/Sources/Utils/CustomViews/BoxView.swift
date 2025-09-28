//
//  BoxView.swift
//  Presentation
//
//  Created by 김영훈 on 9/28/25.
//

import UIKit
import SnapKit

final class BoxView: BaseView {
    
    private let titleLabel: UILabel
    private let lineView = {
        let view = UIView()
        view.backgroundColor = AppColor.border
        return view
    }()
    
    init(title: String) {
        self.titleLabel = UILabel.create(title, color: AppColor.primaryText, font: AppFont.titleS)
        super.init(frame: .zero)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
