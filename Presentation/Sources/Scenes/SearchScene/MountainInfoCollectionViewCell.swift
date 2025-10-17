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

    // 전체 컨테이너 뷰
    private let containerView = {
        let view = UIView()
        view.backgroundColor = AppColor.boxBackground
        view.layer.cornerRadius = AppRadius.radius
        view.layer.borderWidth = 1
        view.layer.borderColor = AppColor.border.cgColor
        view.clipsToBounds = true
        return view
    }()
    
    // 산 아이콘 이미지
    private let imageItemView = ImageItemView(icon: AppIcon.mountain)
    // 높이
    private let heightLabel = TagLabel(text: "", textColor: AppColor.distanceForground, backgroundColor: AppColor.distanceBackground)
    // 산 정보
    private let infoLabel = {
        let label = UILabel.create(color: AppColor.subText, font: AppFont.description)
        label.numberOfLines = 2
        return label
    }()

    // 산 정보 표기
    func configure(with mountainInfo: MountainInfo) {
        imageItemView.setTitle(title: mountainInfo.name)
        imageItemView.setSubtitle(subtitle: mountainInfo.address)
        heightLabel.text = "\(mountainInfo.height)m"
        infoLabel.text = mountainInfo.detail
    }

    // MARK: - Setups
    override func setupHierarchy() {
        contentView.addSubview(containerView)

        [imageItemView, heightLabel, infoLabel].forEach {
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

        infoLabel.snp.makeConstraints { make in
            make.top.equalTo(imageItemView.snp.bottom).offset(AppSpacing.compact)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.regular)
            make.bottom.equalToSuperview().inset(AppSpacing.regular)
        }
    }
}
