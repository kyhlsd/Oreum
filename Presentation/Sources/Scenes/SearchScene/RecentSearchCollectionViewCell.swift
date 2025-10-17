//
//  RecentSearchCollectionViewCell.swift
//  Presentation
//
//  Created by 김영훈 on 10/6/25.
//

import UIKit

final class RecentSearchCollectionViewCell: BaseCollectionViewCell {

    // 전체 컨테이너 뷰
    private let containerView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = AppRadius.radius
        view.layer.borderWidth = 1
        view.layer.borderColor = AppColor.border.cgColor
        view.clipsToBounds = true
        return view
    }()

    // 검색어 레이블
    private let wordLabel = {
        let label = UILabel.create(color: AppColor.primaryText, font: AppFont.tag)
        label.lineBreakMode = .byTruncatingTail
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    // 삭제 버튼
    let deleteButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .regular)
        button.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        button.tintColor = AppColor.subText
        return button
    }()
    
    // 검색어 표기
    func configure(with text: String) {
        wordLabel.text = text
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    // MARK: - Setups
    override func setupHierarchy() {
        contentView.addSubview(containerView)
        [wordLabel, deleteButton].forEach {
            containerView.addSubview($0)
        }
    }
    
    override func setupLayout() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(32)
            make.width.lessThanOrEqualTo(200)
        }

        wordLabel.snp.makeConstraints { make in
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
