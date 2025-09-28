//
//  ImageCollectionViewCell.swift
//  Presentation
//
//  Created by 김영훈 on 9/28/25.
//

import UIKit

final class ImageCollectionViewCell: BaseCollectionViewCell {
    
    override func setupView() {
        backgroundColor = .gray
    }
    
    func setImage(image: String) {
        print(image)
    }
}
