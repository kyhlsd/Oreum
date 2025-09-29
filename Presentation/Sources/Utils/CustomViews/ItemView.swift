//
//  ItemView.swift
//  Presentation
//
//  Created by 김영훈 on 9/28/25.
//

import UIKit
import SnapKit

final class ItemView: BaseView {
    
    private let circleImageView = {
        let imageView = UIImageView()
        imageView.image = AppIcon.circleFill
        imageView.contentMode = .scaleToFill
        imageView.tintColor = AppColor.secondary
        return imageView
    }()
    
    private let iconImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.tintColor = AppColor.primary
        return imageView
    }()
    
    private let titleLabel = UILabel.create(color: AppColor.primaryText, font: AppFont.titleS)
    
    private let subtitleLabel = UILabel.create(color: AppColor.subText, font: AppFont.description)
    
    init(icon: UIImage?, subtitle: String) {
        super.init(frame: .zero)
        iconImageView.image = icon
        subtitleLabel.text = subtitle
    }
    
    func setTitle(title: String?) {
        titleLabel.text = title
    }
    
    override func setupHierarchy() {
        [circleImageView, iconImageView, titleLabel, subtitleLabel].forEach {
            addSubview($0)
        }
    }
    
    override func setupLayout() {
        circleImageView.snp.makeConstraints { make in
            make.verticalEdges.leading.equalToSuperview()
            make.width.equalTo(circleImageView.snp.height)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.edges.equalTo(circleImageView).inset(14)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(circleImageView.snp.trailing).offset(AppSpacing.small)
            make.bottom.equalTo(circleImageView.snp.centerY)
            make.trailing.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(circleImageView.snp.centerY)
            make.trailing.equalToSuperview()
        }
    }
}
