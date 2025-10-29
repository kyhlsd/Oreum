//
//  MountainAnnotationCalloutView.swift
//  Presentation
//
//  Created by 김영훈 on 10/5/25.
//

import UIKit
import Domain
import SnapKit

final class MountainAnnotationCalloutView: BaseView {

    // 산 이름
    private let nameLabel = UILabel.create(color: AppColor.primaryText, font: AppFont.titleS)
    // 산 높이
    private let heightLabel = UILabel.create(color: AppColor.subText, font: AppFont.description)
    // 주소
    private let addressLabel = UILabel.create(color: AppColor.subText, font: AppFont.description)
    // 거리
    private let distanceTagLabel = TagLabel(text: "", textColor: AppColor.distanceForground, backgroundColor: AppColor.distanceBackground)
    // 상세 정보 보기 버튼
    let infoButton = {
        let button = UIButton()
        button.setTitle("상세 정보 보기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = AppColor.primary
        button.titleLabel?.font = AppFont.titleS
        button.layer.cornerRadius = AppRadius.medium
        return button
    }()

    // 산 정보 표기
    func configure(with mountainDistance: MountainDistance) {
        nameLabel.text = mountainDistance.mountainLocation.name
        heightLabel.text = mountainDistance.mountainLocation.height.formatted() + "m"
        distanceTagLabel.text = String(format: "%.1fkm", mountainDistance.distance)
        addressLabel.text = mountainDistance.mountainLocation.address
    }

    // MARK: - Setups
    override func setupHierarchy() {
        [nameLabel, heightLabel, distanceTagLabel, addressLabel, infoButton].forEach {
            addSubview($0)
        }
    }

    override func setupLayout() {
        nameLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(AppSpacing.small)
        }

        heightLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(AppSpacing.small)
            make.lastBaseline.equalTo(nameLabel)
        }

        distanceTagLabel.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(heightLabel.snp.trailing).offset(4)
            make.trailing.equalToSuperview().inset(AppSpacing.small)
            make.centerY.equalTo(nameLabel)
        }

        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.small)
        }

        infoButton.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(AppSpacing.regular)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.small)
            make.bottom.equalToSuperview().inset(AppSpacing.small)
            make.height.equalTo(32)
            make.width.greaterThanOrEqualTo(180)
        }
    }

}
