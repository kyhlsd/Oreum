//
//  ImageCollectionViewCell.swift
//  Presentation
//
//  Created by 김영훈 on 9/28/25.
//

import UIKit
import SnapKit
import Kingfisher

final class ImageCollectionViewCell: BaseCollectionViewCell {

    private let imageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    func setImage(imageData: Data) {
        if let image = UIImage(data: imageData) {
            imageView.image = image
        } else {
            imageView.image = nil
        }
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
