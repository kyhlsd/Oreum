//
//  ClimbRecordCollectionViewCell.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit
import Domain
import SnapKit

class ClimbRecordCollectionViewCell: BaseCollectionViewCell {
    
    let mountainImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private let nameLabel = UILabel.create(color: AppColor.primaryText, font: AppFont.titleS)
    
    private let dateLabel = UILabel.create(color: AppColor.subText, font: AppFont.description)
    
    private let bookmarkButton = {
        let button = UIButton()
        button.tintColor = AppColor.primary
        return button
    }()
    
    final override func prepareForReuse() {
        super.prepareForReuse()
        mountainImageView.image = nil
    }
    
    final func setData(_ data: ClimbRecord) {
        let date = data.timeLog.first?.time
        mountainImageView.image = getMountainImage(date: date)
        nameLabel.text = data.mountainName
        if let date {
            dateLabel.text = AppFormatter.dateFormatter.string(from: date)
        } else {
            dateLabel.text = nil
        }
        
        let image = data.isBookmarked ? AppIcon.bookmarkFill : AppIcon.bookmark
        bookmarkButton.setImage(image, for: .normal)
    }
    
    private func getMountainImage(date: Date?) -> UIImage? {
        guard let date else {
            return UIImage(named: "spring")
        }
        
        let month = Calendar.current.component(.month, from: date)
        let bundle = Bundle.module
        
        switch month {
        case 3...5:
            return UIImage(named: "spring", in: bundle, with: nil)
        case 6...8:
            return UIImage(named: "summer", in: bundle, with: nil)
        case 9...11:
            return UIImage(named: "fall", in: bundle, with: nil)
        default:
            return UIImage(named: "winter", in: bundle, with: nil)
        }
    }
    
    final override func setupView() {
        contentView.backgroundColor = .clear
    }
    
    override func setupHierarchy() {
        [mountainImageView, nameLabel, dateLabel, bookmarkButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    override func setupLayout() {
        nameLabel.snp.makeConstraints { make in
            make.bottom.equalTo(mountainImageView.snp.centerY)
            make.leading.equalTo(mountainImageView.snp.trailing).offset(AppSpacing.regular)
            make.trailing.equalTo(bookmarkButton.snp.leading)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(mountainImageView.snp.centerY)
            make.horizontalEdges.equalTo(nameLabel)
        }
        
        bookmarkButton.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.centerY.trailing.equalToSuperview()
        }
    }
    
}
