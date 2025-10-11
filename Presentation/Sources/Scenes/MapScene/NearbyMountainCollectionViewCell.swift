//
//  NearbyMountainCollectionViewCell.swift
//  Presentation
//
//  Created by @� on 10/4/25.
//

import UIKit
import Domain
import SnapKit

final class NearbyMountainCollectionViewCell: BaseCollectionViewCell {

    private let containerView = {
        let view = UIView()
        view.backgroundColor = AppColor.boxBackground
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = AppColor.border.cgColor
        view.clipsToBounds = true
        return view
    }()

    private let imageItemView = ImageItemView(icon: AppIcon.mountain)

    private let distanceLabel = TagLabel(text: "", textColor: AppColor.distanceForground, backgroundColor: AppColor.distanceBackground)
    
    func configure(mountainLocation: MountainLocation, distance: Double) {
        imageItemView.setTitle(title: mountainLocation.name)
        imageItemView.setSubtitle(subtitle: mountainLocation.address)
        
        if distance == Double.infinity {
            distanceLabel.text = "-"
        } else {
            distanceLabel.text = String(format: "%.1fkm", distance)
        }
    }

    override func setupHierarchy() {
        contentView.addSubview(containerView)

        [imageItemView, distanceLabel].forEach {
            containerView.addSubview($0)
        }
    }

    override func setupLayout() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        imageItemView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(AppSpacing.regular)
            make.verticalEdges.equalToSuperview().inset(AppSpacing.regular)
            make.trailing.lessThanOrEqualTo(distanceLabel.snp.leading).offset(-AppSpacing.compact)
        }

        distanceLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(AppSpacing.regular)
            make.centerY.equalToSuperview()
        }
    }

}
