//
//  ClimbRecordEvenCollectionViewCell.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit
import SnapKit

final class ClimbRecordEvenCollectionViewCell: ClimbRecordCollectionViewCell {
    
    override func setupLayout() {
        super.setupLayout()
        mountainImageView.snp.makeConstraints { make in
            make.size.equalTo(70)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(40)
        }
    }
    
}
