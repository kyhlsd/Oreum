//
//  ImageCollectionViewCell.swift
//  Presentation
//
//  Created by 김영훈 on 9/28/25.
//

import UIKit
import SnapKit

final class ImageCollectionViewCell: BaseCollectionViewCell {
    
    private let imageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    override func setupView() {
        backgroundColor = .clear
    }
    
    override func setupHierarchy() {
        contentView.addSubview(imageView)
    }
    
    override func setupLayout() {
        imageView.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
    }
    
    func setImage(image: String) {
        print(image)
        let temp = "star"
        imageView.image = UIImage(systemName: temp)
    }
}
