//
//  ClimbRecordCollectionViewCell.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit
import Combine
import Domain
import SnapKit

final class ClimbRecordCollectionViewCell: BaseCollectionViewCell {

    private let mountainImageSize = 80
    var bookmarkTapped: ((String) -> Void)?
    private var cancellables = Set<AnyCancellable>()
    
    // 상단 길 이미지
    private let upRoadImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    // 하단 길 이미지
    private let downRoadImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    // 산 이미지
    private let mountainImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    // 산 이름
    private let nameLabel = UILabel.create(color: AppColor.primaryText, font: AppFont.titleM)
    
    // 산 주소
    private let dateLabel = UILabel.create(color: AppColor.subText, font: AppFont.body)
    
    // 태그
    private let tagStackView = TagStackView()
    
    // 북마크 버튼
    private let bookmarkButton = {
        let button = UIButton()
        button.tintColor = AppColor.primary
        return button
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mountainImageView.image = nil
        upRoadImageView.image = nil
        downRoadImageView.image = nil
        bookmarkTapped = nil
        cancellables = Set<AnyCancellable>()
    }
    
    // 데이터 정보 표기
    final func setData(_ data: ClimbRecord, isFirstVisit: Bool) {
        let name = data.mountain.name

        mountainImageView.image = getMountainImage(date: data.climbDate)
        nameLabel.text = name
        dateLabel.text = AppFormatter.dateFormatter.string(from: data.climbDate)

        let image = data.isBookmarked ? AppIcon.bookmarkFill : AppIcon.bookmark
        bookmarkButton.setImage(image, for: .normal)

        tagStackView.setData(isFirstVisit: isFirstVisit, hasLog: !data.timeLog.isEmpty)

        bookmarkButton.tap
            .sink { [weak self] in
                self?.bookmarkTapped?(data.id)
            }
            .store(in: &cancellables)
    }
    
    // 길 이미지 세팅
    func setImages(row: Int, total: Int) {
        let isFirst = row == 0
        let isLast = row == total - 1
        let isEven = row % 2 == 0
        
        setUpRoadImageHidden(isFirst: isFirst)
        setDownRoadImageHidden(isLast: isLast)
        setRoadImages(isEven: isEven)
    }
    
    // 상단 길 이미지 Visibility
    private func setUpRoadImageHidden(isFirst: Bool) {
        upRoadImageView.isHidden = isFirst
    }
    
    // 하단 길 이미지 Visibility
    private func setDownRoadImageHidden(isLast: Bool) {
        downRoadImageView.isHidden = isLast
    }
    
    // 이미지 설정
    private func setRoadImages(isEven: Bool) {
        if isEven {
            upRoadImageView.image = UIImage(named: "road4", in: .module, with: nil)
            downRoadImageView.image = UIImage(named: "road1", in: .module, with: nil)
            mountainImageView.snp.updateConstraints { make in
                make.leading.equalToSuperview()
            }
        } else {
            upRoadImageView.image = UIImage(named: "road2", in: .module, with: nil)
            downRoadImageView.image = UIImage(named: "road3", in: .module, with: nil)
            mountainImageView.snp.updateConstraints { make in
                make.leading.equalToSuperview().offset(mountainImageSize / 2)
            }
        }
    }
    
    // 계절에 따라 다른 산 이미지
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
    
    // MARK: Setups
    override func setupView() {
        contentView.backgroundColor = .clear
    }
    
    override func setupHierarchy() {
        [upRoadImageView, downRoadImageView, mountainImageView, nameLabel, dateLabel, tagStackView, bookmarkButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    override func setupLayout() {
        
        upRoadImageView.snp.makeConstraints { make in
            make.width.equalTo(mountainImageSize)
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(mountainImageSize / 2)
            make.bottom.equalTo(mountainImageView.snp.centerY)
        }
        
        downRoadImageView.snp.makeConstraints { make in
            make.width.equalTo(mountainImageSize)
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(mountainImageSize / 2)
            make.top.equalTo(mountainImageView.snp.centerY)
        }
        
        mountainImageView.snp.makeConstraints { make in
            make.size.equalTo(mountainImageSize)
            make.centerY.leading.equalToSuperview()
        }
        
        nameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        nameLabel.snp.makeConstraints { make in
            make.bottom.equalTo(mountainImageView.snp.centerY)
            make.leading.equalTo(mountainImageView.snp.trailing).offset(AppSpacing.compact)
            make.trailing.equalTo(tagStackView.snp.leading).offset(-AppSpacing.small)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(mountainImageView.snp.centerY)
            make.horizontalEdges.equalTo(nameLabel)
        }

        tagStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(bookmarkButton.snp.leading)
        }
        
        bookmarkButton.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.centerY.trailing.equalToSuperview()
        }
    }
    
}
