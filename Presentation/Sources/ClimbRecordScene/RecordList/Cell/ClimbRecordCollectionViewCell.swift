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
    weak var cellBookmarkTapSubject: PassthroughSubject<String, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    private let upRoadImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private let downRoadImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private let mountainImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private let nameLabel = UILabel.create(color: AppColor.primaryText, font: AppFont.titleS)
    
    private let dateLabel = UILabel.create(color: AppColor.subText, font: AppFont.description)
    
    private let tagStackView = TagStackView()
    
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
        cellBookmarkTapSubject = nil
        cancellables = Set<AnyCancellable>()
    }
    
    final func setData(_ data: ClimbRecord) {
        // TODO: DTO, model 재정의
        let mountains = Mountain.dummy
        let mountain = mountains.filter { $0.id == data.mountainId }.first!
        let isFamous = mountain.isFamous
        let record = ClimbRecord.dummy.filter { $0.mountainId == data.mountainId }.first!
        let isFirstVisit = record.id == data.id
        let name = mountain.name
        
        let date = data.timeLog.first?.time
        mountainImageView.image = getMountainImage(date: date)
        nameLabel.text = name
        if let date {
            dateLabel.text = AppFormatter.dateFormatter.string(from: date)
        } else {
            dateLabel.text = nil
        }
        
        let image = data.isBookmarked ? AppIcon.bookmarkFill : AppIcon.bookmark
        bookmarkButton.setImage(image, for: .normal)
        
        tagStackView.setData(isFirstVisit: isFirstVisit, isFamous: isFamous)
        
        bookmarkButton.tap
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] in
                self?.cellBookmarkTapSubject?.send(data.id)
                
            }
            .store(in: &cancellables)
    }
    
    func setImages(row: Int, total: Int) {
        let isFirst = row == 0
        let isLast = row == total - 1
        let isEven = row % 2 == 0
        
        setUpRoadImageHidden(isFirst: isFirst)
        setDownRoadImageHidden(isLast: isLast)
        setRoadImages(isEven: isEven)
    }
    
    private func setUpRoadImageHidden(isFirst: Bool) {
        upRoadImageView.isHidden = isFirst
    }
    
    private func setDownRoadImageHidden(isLast: Bool) {
        downRoadImageView.isHidden = isLast
    }
    
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
            make.leading.equalTo(mountainImageView.snp.trailing).offset(AppSpacing.regular)
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
