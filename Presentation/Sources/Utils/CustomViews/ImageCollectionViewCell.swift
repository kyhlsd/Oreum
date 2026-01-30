//
//  ImageCollectionViewCell.swift
//  Presentation
//
//  Created by 김영훈 on 9/28/25.
//

import UIKit
import Domain
import SnapKit
import Kingfisher

final class ImageCollectionViewCell: BaseCollectionViewCell {

    private let imageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.kf.indicatorType = .activity
        return imageView
    }()

    func setImage(imageData: ImageItem) {
        if let image = UIImage(data: imageData.data) {
            imageView.image = image
        } else {
            imageView.image = nil
        }
    }

    func setImage(urlString: String) {
        guard let url = URL(string: urlString) else {
            imageView.image = nil
            return
        }
        imageView.kf.setImage(
            with: url,
            options: [
                .backgroundDecode,
                .processor(DownsamplingImageProcessor(size: CGSize(width: DeviceSize.width, height: DeviceSize.width * 0.75))),
                .scaleFactor(DeviceSize.scale)
            ]
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    // MARK: - Setups
    
    override func setupView() {
        backgroundColor = .clear
    }

    override func setupHierarchy() {
        contentView.addSubview(imageView)
    }

    override func setupLayout() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
