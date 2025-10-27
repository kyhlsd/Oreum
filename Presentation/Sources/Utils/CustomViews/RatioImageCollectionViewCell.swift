//
//  RatioImageCollectionViewCell.swift
//  Presentation
//
//  Created by Claude Code
//

import UIKit
import SnapKit

final class RatioImageCollectionViewCell: BaseCollectionViewCell {

    private let imageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = AppRadius.medium
        imageView.backgroundColor = AppColor.background
        return imageView
    }()

    private let activityIndicator = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = AppColor.primary
        return indicator
    }()

    private let emptyLabel = {
        let label = UILabel.create(color: AppColor.subText, font: AppFont.tag)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    func setImage(imageData: Data) {
        // 빈 Data면 로딩 중 상태
        guard !imageData.isEmpty else {
            activityIndicator.startAnimating()
            emptyLabel.isHidden = true
            imageView.image = nil
            return
        }

        // 이미 Data가 있으므로 동기적으로 변환
        guard let image = UIImage(data: imageData) else {
            activityIndicator.stopAnimating()
            emptyLabel.isHidden = false
            imageView.image = nil
            return
        }

        imageView.image = image
        activityIndicator.stopAnimating()
        emptyLabel.isHidden = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        activityIndicator.stopAnimating()
        emptyLabel.isHidden = true
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        let height = layoutAttributes.size.height

        guard let image = imageView.image else {
            // 이미지가 없으면 (로딩 중이거나 실패) 정사각형으로 표시
            attributes.size = CGSize(width: height, height: height)
            return attributes
        }

        // 높이는 고정, 너비는 이미지 비율에 맞춰 계산
        let aspectRatio = image.size.width / image.size.height
        let width = height * aspectRatio

        attributes.size = CGSize(width: width, height: height)

        return attributes
    }

    // MARK: - Setups

    override func setupView() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    override func setupHierarchy() {
        contentView.addSubview(imageView)
        contentView.addSubview(activityIndicator)
        contentView.addSubview(emptyLabel)
    }

    override func setupLayout() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.small)
        }
    }
}
