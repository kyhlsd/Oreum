//
//  MountainInfoView.swift
//  Presentation
//
//  Created by 김영훈 on 10/5/25.
//

import UIKit
import Domain
import SnapKit

final class MountainInfoView: BaseView {

    private let scrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()

    private let contentView = UIView()

    let imageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = AppColor.cardBackground
        return imageView
    }()

    private let infoView = BoxView(title: "정보")

    private let addressView = ImageItemView(icon: AppIcon.address, subtitle: "주소")
    private let heightView = ImageItemView(icon: AppIcon.mountain, subtitle: "높이")

    private let introductionView = BoxView(title: "산 소개")

    private let introductionLabel = {
        let label = UILabel()
        label.font = AppFont.body
        label.textColor = AppColor.subText
        label.numberOfLines = 0
        return label
    }()

    private let weatherView = BoxView(title: "날씨 정보")

    private let weatherContentView = UIView()

    override func setupView() {
        backgroundColor = AppColor.background
    }

    override func setupHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        [imageView, infoView, introductionView, weatherView].forEach {
            contentView.addSubview($0)
        }

        [addressView, heightView].forEach {
            infoView.addSubview($0)
        }

        introductionView.addSubview(introductionLabel)

        weatherView.addSubview(weatherContentView)
    }

    override func setupLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
        }

        imageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(imageView.snp.width).multipliedBy(0.75)
        }

        infoView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(AppSpacing.regular)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.regular)
        }

        addressView.snp.makeConstraints { make in
            make.top.equalTo(infoView.lineView.snp.bottom).offset(AppSpacing.compact)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.compact)
            make.height.equalTo(48)
        }

        heightView.snp.makeConstraints { make in
            make.top.equalTo(addressView.snp.bottom).offset(AppSpacing.compact)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.compact)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().inset(AppSpacing.compact)
        }

        introductionView.snp.makeConstraints { make in
            make.top.equalTo(infoView.snp.bottom).offset(AppSpacing.regular)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.regular)
        }

        introductionLabel.snp.makeConstraints { make in
            make.top.equalTo(introductionView.lineView.snp.bottom).offset(AppSpacing.compact)
            make.horizontalEdges.bottom.equalToSuperview().inset(AppSpacing.compact)
        }

        weatherView.snp.makeConstraints { make in
            make.top.equalTo(introductionView.snp.bottom).offset(AppSpacing.regular)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.regular)
            make.bottom.equalToSuperview().inset(AppSpacing.regular)
        }

        weatherContentView.snp.makeConstraints { make in
            make.top.equalTo(weatherView.lineView.snp.bottom).offset(AppSpacing.compact)
            make.horizontalEdges.bottom.equalToSuperview().inset(AppSpacing.compact)
            make.height.equalTo(100)
        }
    }
}

// MARK: - Binding Methods
extension MountainInfoView {
    func configure(with mountainInfo: MountainInfo) {
        addressView.setTitle(title: mountainInfo.address)
        heightView.setTitle(title: "\(mountainInfo.height)m")
        introductionLabel.text = mountainInfo.detail
    }
}
