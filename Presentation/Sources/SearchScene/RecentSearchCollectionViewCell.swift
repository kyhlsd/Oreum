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

    private let label = UILabel.create(color: AppColor.primaryText, font: AppFont.tag)

    let deleteButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .regular)
        button.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        button.tintColor = AppColor.subText
        return button
    }()
    
    func configure(with text: String) {
        label.text = text
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
        }

        label.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(AppSpacing.small)
            make.leading.equalToSuperview().inset(AppSpacing.compact)
        }

        deleteButton.snp.makeConstraints { make in
            make.leading.equalTo(label.snp.trailing).offset(AppSpacing.small)
            make.trailing.equalToSuperview().inset(AppSpacing.small)
            make.centerY.equalToSuperview()
            make.size.equalTo(16)
        }
    }

}
