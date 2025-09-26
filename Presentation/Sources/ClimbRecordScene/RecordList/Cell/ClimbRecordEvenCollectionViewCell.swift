//
//  ClimbRecordEvenCollectionViewCell.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit
import SnapKit

final class ClimbRecordEvenCollectionViewCell: ClimbRecordCollectionViewCell {
    
    override func setupView() {
        super.setupView()
        upRoadImageView.image = UIImage(named: "road4", in: .module, with: nil)
        downRoadImageView.image = UIImage(named: "road1", in: .module, with: nil)
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        upRoadImageView.snp.makeConstraints { make in
            make.width.equalTo(mountainImageSize)
            make.top.equalToSuperview()
            make.leading.equalTo(mountainImageView.snp.centerX)
            make.bottom.equalTo(mountainImageView.snp.centerY)
        }
        
        downRoadImageView.snp.makeConstraints { make in
            make.width.equalTo(mountainImageSize)
            make.bottom.equalToSuperview()
            make.leading.equalTo(mountainImageView.snp.centerX)
            make.top.equalTo(mountainImageView.snp.centerY)
        }
        
        mountainImageView.snp.makeConstraints { make in
            make.size.equalTo(mountainImageSize)
            make.centerY.leading.equalToSuperview()
        }
    }
    
}
