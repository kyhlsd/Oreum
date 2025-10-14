//
//  RecentSearchCollectionViewCell.swift
//  Presentation
//
//  Created by 김영훈 on 10/6/25.
//

import UIKit

final class RecentSearchCollectionViewCell: BaseCollectionViewCell {

    private let containerView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = AppRadius.radius
        view.layer.borderWidth = 1
        view.layer.borderColor = AppColor.border.cgColor
        view.clipsToBounds = true
        return view
    }()

    private let label = {
        let label = UILabel.create(color: AppColor.primaryText, font: AppFont.tag)
        label.lineBreakMode = .byTruncatingTail
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    let deleteButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .regular)
        button.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        button.tintColor = AppColor.subText
        return button
    }()
    
    func configure(with text: String) {
        label.text = text
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override func setupHierarchy() {
        contentView.addSubview(containerView)
        [label, deleteButton].forEach {
            containerView.addSubview($0)
        }
    }
    
    override func setupLayout() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(32)
            make.width.lessThanOrEqualTo(200)
        }

        label.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(AppSpacing.small)
            make.leading.equalToSuperview().inset(AppSpacing.compact)
            make.trailing.equalTo(deleteButton.snp.leading).offset(-AppSpacing.small)
        }

        deleteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(AppSpacing.small)
            make.centerY.equalToSuperview()
            make.size.equalTo(16)
        }
    }

}
