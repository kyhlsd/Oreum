//
//  MountainInfoView.swift
//  Presentation
//
//  Created by 김영훈 on 10/5/25.
//

import UIKit
import Domain
import SnapKit
import Kingfisher

final class MountainInfoView: BaseView {

    private let scrollView = UIScrollView()

    private let contentView = UIView()

    private let imageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = AppColor.cardBackground
        return imageView
    }()

    private let emptyImageView = {
        let view = UIView()
        view.backgroundColor = AppColor.cardBackground
        view.isHidden = true
        return view
    }()

    private let photoImageView = {
        let imageView = UIImageView()
        imageView.image = AppIcon.photo
        imageView.tintColor = AppColor.subText
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let photoLabel = {
        let label = UILabel.create("이미지가 없습니다", color: AppColor.subText, font: AppFont.label)
        label.textAlignment = .center
        return label
    }()

    private let infoView = BoxView(title: "정보")

    private let addressView = ImageItemView(icon: AppIcon.address, subtitle: "주소")
    private let heightView = ImageItemView(icon: AppIcon.mountain, subtitle: "높이")

    private let introductionView = BoxView(title: "산 소개")

    private let introductionTextView = {
        let textView = UITextView(usingTextLayoutManager: false)
        textView.textContainerInset = UIEdgeInsets(top: AppSpacing.compact, left: AppSpacing.compact, bottom: AppSpacing.compact, right: AppSpacing.compact)
        textView.textContainer.lineFragmentPadding = 0
        textView.isScrollEnabled = false
        textView.isEditable = false
        return textView
    }()

    private let weatherView = BoxView(title: "날씨 정보")

    private let weatherContentView = UIView()

    override func setupView() {
        backgroundColor = AppColor.background
    }

    override func setupHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        [imageView, emptyImageView, infoView, introductionView, weatherView].forEach {
            contentView.addSubview($0)
        }

        [photoImageView, photoLabel].forEach {
            emptyImageView.addSubview($0)
        }

        [addressView, heightView].forEach {
            infoView.addSubview($0)
        }

        introductionView.addSubview(introductionTextView)

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

        emptyImageView.snp.makeConstraints { make in
            make.edges.equalTo(imageView)
        }

        photoImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(100)
        }

        photoLabel.snp.makeConstraints { make in
            make.top.equalTo(photoImageView.snp.bottom).offset(AppSpacing.compact)
            make.centerX.equalToSuperview()
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

        introductionTextView.snp.makeConstraints { make in
            make.top.equalTo(introductionView.lineView.snp.bottom)
            make.horizontalEdges.bottom.equalToSuperview()
            make.height.greaterThanOrEqualTo(20)
            make.height.lessThanOrEqualTo(180)
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

    func setAddress(_ address: String) {
        addressView.setTitle(title: address)
    }

    func setHeight(_ height: String) {
        heightView.setTitle(title: height)
    }

    func setIntroduction(_ attributedText: NSAttributedString) {
        introductionTextView.attributedText = attributedText
    }

    func setImage(_ url: URL?) {
        if let url = url {
            imageView.kf.setImage(with: url, options: [
                .processor(DownsamplingImageProcessor(size: CGSize(width: DeviceSize.width, height: DeviceSize.width * 0.75))),
                .scaleFactor(DeviceSize.scale)
            ])
            emptyImageView.isHidden = true
        } else {
            emptyImageView.isHidden = false
        }
    }

    func calculateTextViewHeight(width: CGFloat) -> CGFloat {
        let size = introductionTextView.sizeThatFits(CGSize(width: width, height: .infinity))
        return size.height
    }

    func setTextViewScrollEnabled(_ enabled: Bool) {
        introductionTextView.isScrollEnabled = enabled
    }
}
