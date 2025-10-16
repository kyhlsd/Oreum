//
//  MeasureCompleteView.swift
//  Presentation
//
//  Created by 김영훈 on 10/7/25.
//

import UIKit
import SnapKit

final class MeasureCompleteView: BaseView {

    // 전체 컨테이너 뷰
    private let containerView = {
        let view = UIView()
        view.backgroundColor = AppColor.background
        view.layer.cornerRadius = AppRadius.radius
        return view
    }()

    // 측정 완료 레이블
    private let titleLabel = {
        let label = UILabel.create("측정이 완료되었습니다.", color: AppColor.primaryText, font: AppFont.titleM)
        label.textAlignment = .center
        return label
    }()
    // 메세지 레이블
    private let messageLabel = {
        let label = UILabel.create(
            "'기록'에서 사진과 후기를 추가해\n기록을 더 풍성하게 남겨보세요",
            color: AppColor.subText,
            font: AppFont.body
        )
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    // 지금 추가 버튼
    let addDetailButton = CustomButton(title: "지금 추가하기", image: nil, foreground: .white, background: AppColor.primary)
    // 나중에 추가 버튼
    let confirmButton = CustomButton(title: "나중에 추가하기", image: nil, foreground: AppColor.subText, background: AppColor.boxBackground, hasBorder: true)

    // MARK: - Setups
    override func setupView() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }

    override func setupHierarchy() {
        addSubview(containerView)
        [titleLabel, messageLabel, addDetailButton, confirmButton].forEach {
            containerView.addSubview($0)
        }
    }

    override func setupLayout() {
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview().inset(AppSpacing.regular)
        }

        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(AppSpacing.regular)
            make.leading.trailing.equalToSuperview().inset(AppSpacing.regular)
        }

        addDetailButton.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(24)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.regular)
            make.height.equalTo(40)
        }

        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(addDetailButton.snp.bottom).offset(AppSpacing.compact)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.regular)
            make.bottom.equalToSuperview().offset(-24)
            make.height.equalTo(40)
        }
    }
}
