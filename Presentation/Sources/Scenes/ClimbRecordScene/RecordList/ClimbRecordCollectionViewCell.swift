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

    private let mountainImageSize = 60
    var bookmarkTapped: ((String) -> Void)?
    private var cancellables = Set<AnyCancellable>()
    private lazy var dataSource = createDataSource()
    
    // 컨테이너 뷰
    private let containerView = {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = AppRadius.large
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 8
        containerView.layer.masksToBounds = false
        return containerView
    }()
    
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
    private let nameLabel = UILabel.create(color: AppColor.primaryText, font: AppFont.titleS)
    
    // 등산 날짜
    private let dateLabel = UILabel.create(color: AppColor.subText, font: AppFont.description)
    
    // 태그
    private let tagStackView = TagStackView()
    
    // 북마크 버튼
    private let bookmarkButton = {
        let button = UIButton()
        button.tintColor = AppColor.primary
        return button
    }()
    
    // 이미지 컬렉션뷰
    private lazy var imageCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createImageCollectionViewLayout())
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.isUserInteractionEnabled = false
        return collectionView
    }()

    // 후기 레이블
    private let commentLabel = {
        let label = UILabel.create(color: AppColor.tertiaryText, font: AppFont.description)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        mountainImageView.image = nil
        upRoadImageView.image = nil
        downRoadImageView.image = nil
        bookmarkTapped = nil
        commentLabel.isHidden = true
        imageCollectionView.isHidden = false
        cancellables = Set<AnyCancellable>()
    }
    
    // 데이터 정보 표기
    final func setData(_ data: ClimbRecord, isFirstVisit: Bool, imageDatas: [Data] = []) {
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

        // 이미지 컬렉션뷰 또는 코멘트 표시
        if data.images.isEmpty && !data.comment.isEmpty {
            // 이미지 없고 코멘트 있음
            imageCollectionView.isHidden = true
            commentLabel.isHidden = false
            setComment(text: data.comment)
        } else if data.images.isEmpty {
            // 이미지도 코멘트도 없음
            imageCollectionView.isHidden = true
            commentLabel.isHidden = true
        } else if imageDatas.isEmpty {
            // 로딩 중: placeholder
            imageCollectionView.isHidden = false
            commentLabel.isHidden = true
            applySnapshot(images: [Data()]) // 빈 Data로 indicator 표시
        } else {
            // 이미지 있음
            imageCollectionView.isHidden = false
            commentLabel.isHidden = true
            applySnapshot(images: imageDatas)
        }
    }
    
    // 후기
    func setComment(text: String) {
        let attributedString = NSMutableAttributedString(string: text)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.lineBreakStrategy = .hangulWordPriority
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))

        commentLabel.attributedText = attributedString
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
                make.leading.equalToSuperview().offset(AppSpacing.compact)
            }
        } else {
            upRoadImageView.image = UIImage(named: "road2", in: .module, with: nil)
            downRoadImageView.image = UIImage(named: "road3", in: .module, with: nil)
            mountainImageView.snp.updateConstraints { make in
                make.leading.equalToSuperview().offset(CGFloat(mountainImageSize / 2) + AppSpacing.compact)
            }
        }
    }
    
    // 계절에 따라 다른 산 이미지
    private func getMountainImage(date: Date?) -> UIImage? {
        guard let date else {
            return nil
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
        [containerView, upRoadImageView, downRoadImageView, mountainImageView].forEach {
            contentView.addSubview($0)
        }
        [nameLabel, dateLabel, tagStackView, bookmarkButton, imageCollectionView, commentLabel].forEach {
            containerView.addSubview($0)
        }
    }
    
    override func setupLayout() {
        containerView.snp.makeConstraints { make in
            make.top.equalTo(mountainImageView)
            make.horizontalEdges.bottom.equalToSuperview()
        }
        
        upRoadImageView.snp.makeConstraints { make in
            make.width.equalTo(mountainImageSize)
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(CGFloat(mountainImageSize / 2) + AppSpacing.compact)
            make.bottom.equalTo(mountainImageView.snp.centerY)
        }
        
        downRoadImageView.snp.makeConstraints { make in
            make.width.equalTo(mountainImageSize)
            make.leading.equalToSuperview().offset(CGFloat(mountainImageSize / 2) + AppSpacing.compact)
            make.top.equalTo(mountainImageView.snp.centerY)
            make.height.equalTo(upRoadImageView).multipliedBy(2)
            make.bottom.equalToSuperview().offset(1)
        }
        
        mountainImageView.snp.makeConstraints { make in
            make.size.equalTo(mountainImageSize)
            make.leading.equalToSuperview().offset(AppSpacing.compact)
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
            make.centerY.equalTo(mountainImageView)
            make.trailing.equalTo(bookmarkButton.snp.leading)
        }
        
        bookmarkButton.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.centerY.equalTo(tagStackView)
            make.trailing.equalToSuperview()
        }

        imageCollectionView.snp.makeConstraints { make in
            make.top.equalTo(mountainImageView.snp.bottom)
            make.leading.equalTo(nameLabel)
            make.trailing.equalToSuperview().inset(AppSpacing.compact)
            make.bottom.equalToSuperview().inset(AppSpacing.compact)
        }

        commentLabel.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(imageCollectionView)
            make.bottom.lessThanOrEqualTo(imageCollectionView)
        }
    }

}

// MARK: ImageCollectionView SubMethods
extension ClimbRecordCollectionViewCell {
    private enum Section: CaseIterable {
        case main
    }
    
    private func createImageCollectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .estimated(100),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .estimated(100),
            heightDimension: .fractionalHeight(1)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 4
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func createRegistration() -> UICollectionView.CellRegistration<RatioImageCollectionViewCell, Data> {
        return UICollectionView.CellRegistration<RatioImageCollectionViewCell, Data> { cell, indexPath, item in
            cell.setImage(imageData: item)
        }
    }

    private func createDataSource() -> UICollectionViewDiffableDataSource<Section, Data> {
        let registration = createRegistration()
        return UICollectionViewDiffableDataSource<Section, Data>(collectionView: imageCollectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
        }
    }

    private func applySnapshot(images: [Data]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Data>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(images)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
