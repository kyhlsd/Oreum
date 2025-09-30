//
//  ItemView.swift
//  Presentation
//
//  Created by 김영훈 on 9/30/25.
//

import UIKit
import SnapKit

final class ItemView: BaseView {
    
    private let titleLabel = UILabel.create(color: AppColor.primaryText, font: AppFont.titleS)
    
    private let subtitleLabel = UILabel.create(color: AppColor.subText, font: AppFont.description)
    
    init(subtitle: String) {
        super.init(frame: .zero)
        subtitleLabel.text = subtitle
    }
    
    func setTitle(title: String?) {
        titleLabel.text = title
    }
    
    override func setupView() {
        titleLabel.textAlignment = .center
        subtitleLabel.textAlignment = .center
    }
    
    override func setupHierarchy() {
        [titleLabel, subtitleLabel].forEach {
            addSubview($0)
        }
    }
    
    override func setupLayout() {
        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.top.equalToSuperview()
            make.bottom.equalTo(snp.centerY)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(snp.centerY)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
}
