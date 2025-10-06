//
//  MountainInfoCollectionViewCell.swift
//  Presentation
//
//  Created by 김영훈 on 10/6/25.
//

import UIKit
import Domain
import SnapKit

final class MountainInfoCollectionViewCell: BaseCollectionViewCell {

    private let containerView = {
        let view = UIView()
        view.backgroundColor = AppColor.boxBackground
        view.layer.cornerRadius = AppRadius.radius
        view.layer.borderWidth = 1
        view.layer.borderColor = AppColor.border.cgColor
        view.clipsToBounds = true
        return view
    }()

    private let imageItemView = ImageItemView(icon: AppIcon.mountain)

    private let heightLabel = TagLabel(text: "", textColor: AppColor.distanceForground, backgroundColor: AppColor.distanceBackground)

    private let descriptionLabel = {
        let label = UILabel.create(color: AppColor.subText, font: AppFont.description)
        label.numberOfLines = 2
        return label
    }()

    func configure(with mountainInfo: MountainInfo) {
        imageItemView.setTitle(title: mountainInfo.name)
        imageItemView.setSubtitle(subtitle: mountainInfo.address)
        heightLabel.text = "\(mountainInfo.height)m"
        descriptionLabel.text = mountainInfo.detail
    }

    override func setupHierarchy() {
        contentView.addSubview(containerView)

        [imageItemView, heightLabel, descriptionLabel].forEach {
            containerView.addSubview($0)
        }
    }

    override func setupLayout() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        imageItemView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(AppSpacing.regular)
            make.trailing.lessThanOrEqualTo(heightLabel.snp.leading).offset(-AppSpacing.compact)
            make.height.equalTo(48)
        }

        heightLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(AppSpacing.regular)
            make.centerY.equalTo(imageItemView)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(imageItemView.snp.bottom).offset(AppSpacing.compact)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.regular)
            make.bottom.equalToSuperview().inset(AppSpacing.regular)
        }
    }
}
