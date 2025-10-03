//
//  ClimbRecordDetailView.swift
//  Presentation
//
//  Created by 김영훈 on 9/28/25.
//

import UIKit
import Combine
import Domain
import SnapKit

final class ClimbRecordDetailView: BaseView {
    
    private let scrollView = {
        let scrollView = UIScrollView()
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()
    
    private let contentView = UIView()
    
    lazy var imageCollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = false
        return collectionView
    }()

    let pageControl = {
        let pageControl = UIPageControl()
        pageControl.isUserInteractionEnabled = false
        pageControl.backgroundStyle = .minimal
        pageControl.hidesForSinglePage = true
        return pageControl
    }()

    private let emptyImageView = {
        let view = UIView()
        view.backgroundColor = AppColor.cardBackground
        view.isHidden = true
        return view
    }()

    private let photoImageView = {
        let imageView = UIImageView()
        imageView.image = AppIcon.photo
        imageView.tintColor = AppColor.subText
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let photoLabel = {
        let label = UILabel.create("산에서 담은 순간을 추가해 보세요", color: AppColor.subText, font: AppFont.label)
        label.textAlignment = .center
        return label
    }()

    let editPhotoButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 40)
        button.setImage(AppIcon.editCircle?.withConfiguration(config), for: .normal)
        button.tintColor = AppColor.primary
        return button
    }()

    private let infoView = BoxView(title: "정보")
    
    private let addressView = ImageItemView(icon: AppIcon.address, subtitle: "주소")
    private let dateView = ImageItemView(icon: AppIcon.date, subtitle: "날짜")
    private let heightView = ImageItemView(icon: AppIcon.mountain, subtitle: "높이")
    
    private let reviewView = BoxView(title: "나의 후기")
    
    let commentTextView = {
        let textView = UITextView(usingTextLayoutManager: false)
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.font = AppFont.body
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        textView.typingAttributes = [
            .paragraphStyle: paragraphStyle,
            .font: AppFont.body,
            .foregroundColor: AppColor.subText
        ]
        textView.isScrollEnabled = false
        textView.isEditable = false
        return textView
    }()
    
    let ratingView = StarRatingView()
    
    let editButton = {
        let button = UIButton()
        button.setImage(AppIcon.edit, for: .normal)
        button.tintColor = AppColor.primaryText
        return button
    }()
    
    let saveButton = {
        let button = UIButton()
        button.setImage(AppIcon.save, for: .normal)
        button.tintColor = AppColor.primaryText
        button.isHidden = true
        return button
    }()
    
    let cancelButton = {
        let button = UIButton()
        button.setImage(AppIcon.x, for: .normal)
        button.tintColor = AppColor.danger
        button.isHidden = true
        return button
    }()
    
    let timelineButton = CustomButton(title: "타임라인 보기", image: AppIcon.timeline, foreground: .white, background: AppColor.primary)

    let deleteButton = CustomButton(title: "기록 삭제", image: AppIcon.trash, foreground: AppColor.danger, background: AppColor.dangerText, hasBorder: true)
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: size)

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .zero
        section.orthogonalScrollingBehavior = .groupPaging

        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, point, environment in
            guard let self = self else { return }
            let page = Int(round(point.x / environment.container.contentSize.width))
            self.pageControl.currentPage = page
        }

        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // MARK: - Setups
    override func setupView() {
        backgroundColor = AppColor.background
    }
    
    override func setupHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        [imageCollectionView, emptyImageView, pageControl, editPhotoButton, infoView, reviewView, timelineButton, deleteButton].forEach {
            contentView.addSubview($0)
        }

        [photoImageView, photoLabel].forEach {
            emptyImageView.addSubview($0)
        }

        [addressView, dateView, heightView].forEach {
            infoView.addSubview($0)
        }

        [commentTextView, ratingView, editButton, saveButton, cancelButton].forEach {
            reviewView.addSubview($0)
        }
    }
    
    override func setupLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
        }
        
        imageCollectionView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(imageCollectionView.snp.width).multipliedBy(0.75)
        }

        emptyImageView.snp.makeConstraints { make in
            make.edges.equalTo(imageCollectionView)
        }

        photoImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(100)
        }

        photoLabel.snp.makeConstraints { make in
            make.top.equalTo(photoImageView.snp.bottom).offset(AppSpacing.compact)
            make.centerX.equalToSuperview()
        }

        editPhotoButton.snp.makeConstraints { make in
            make.trailing.equalTo(imageCollectionView).inset(AppSpacing.regular)
            make.bottom.equalTo(imageCollectionView).inset(AppSpacing.regular)
            make.size.equalTo(40)
        }

        pageControl.snp.makeConstraints { make in
            make.bottom.equalTo(imageCollectionView).inset(AppSpacing.regular)
            make.centerX.equalTo(imageCollectionView)
        }
        
        infoView.snp.makeConstraints { make in
            make.top.equalTo(imageCollectionView.snp.bottom).offset(AppSpacing.regular)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.regular)
        }
        
        addressView.snp.makeConstraints { make in
            make.top.equalTo(infoView.lineView.snp.bottom).offset(AppSpacing.compact)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.compact)
            make.height.equalTo(48)
        }
        
        dateView.snp.makeConstraints { make in
            make.top.equalTo(addressView.snp.bottom).offset(AppSpacing.compact)
            make.leading.equalToSuperview().inset(AppSpacing.compact)
            make.trailing.equalTo(infoView.snp.centerX).inset(AppSpacing.small / 2)
            make.height.equalTo(addressView)
            make.bottom.equalToSuperview().inset(AppSpacing.compact)
        }
        
        heightView.snp.makeConstraints { make in
            make.top.equalTo(addressView.snp.bottom).offset(AppSpacing.compact)
            make.leading.equalTo(infoView.snp.centerX).offset(AppSpacing.small / 2)
            make.trailing.equalToSuperview().inset(AppSpacing.compact)
            make.height.equalTo(addressView)
            make.bottom.equalToSuperview().inset(AppSpacing.compact)
        }
        
        reviewView.snp.makeConstraints { make in
            make.top.equalTo(infoView.snp.bottom).offset(AppSpacing.regular)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.regular)
        }
        
        commentTextView.snp.makeConstraints { make in
            make.top.equalTo(reviewView.lineView.snp.bottom).offset(AppSpacing.compact)
            make.horizontalEdges.bottom.equalToSuperview().inset(AppSpacing.compact)
            make.height.greaterThanOrEqualTo(20)
            make.height.lessThanOrEqualTo(144)
        }
        
        ratingView.snp.makeConstraints { make in
            make.verticalEdges.equalTo(reviewView.titleLabel)
            make.leading.equalTo(reviewView.titleLabel.snp.trailing).offset(AppSpacing.compact)
        }
        
        editButton.snp.makeConstraints { make in
            make.verticalEdges.equalTo(reviewView.titleLabel)
            make.width.equalTo(editButton.snp.height)
            make.trailing.equalToSuperview().inset(AppSpacing.compact)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.edges.equalTo(editButton)
        }
        
        saveButton.snp.makeConstraints { make in
            make.size.verticalEdges.equalTo(cancelButton)
            make.trailing.equalTo(cancelButton.snp.leading).offset(-AppSpacing.small)
        }
        
        timelineButton.snp.makeConstraints { make in
            make.top.equalTo(reviewView.snp.bottom).offset(AppSpacing.regular)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.regular)
            make.height.equalTo(44)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(timelineButton.snp.bottom).offset(AppSpacing.small)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.regular)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().inset(AppSpacing.regular)
        }
    }
}

// MARK: - Binding Methods
extension ClimbRecordDetailView {
    
    func adjustForKeyboard(height: CGFloat) {
        scrollView.contentInset.bottom = height
        scrollView.verticalScrollIndicatorInsets.bottom = height
    }
    
    func setData(climbRecord: ClimbRecord) {
        // TODO: 메서드로 만들기
        if let date = climbRecord.timeLog.first?.time {
            dateView.setTitle(title: AppFormatter.dateFormatter.string(from: date))
        } else {
            dateView.setTitle(title: "기록 없음")
        }

        addressView.setTitle(title: climbRecord.mountain.address)
        heightView.setTitle(title: climbRecord.mountain.height.formatted() + "m")
        
        setReview(rating: climbRecord.score, comment: climbRecord.comment)
    }
    
    func setEditable(_ isEditable: Bool) {
        commentTextView.isEditable = isEditable
        ratingView.setEditable(isEditable)
        editButton.isHidden = isEditable
        saveButton.isHidden = !isEditable
        cancelButton.isHidden = !isEditable
    }
    
    func setReview(rating: Int, comment: String) {
        ratingView.setRating(rating: rating, animated: true)
        commentTextView.text = comment
    }

    func setTimelineButtonEnabled(_ isEnabled: Bool) {
        timelineButton.isEnabled = isEnabled
        timelineButton.alpha = isEnabled ? 1.0 : 0.5
    }

    func setTimelineButtonTitle(_ title: String) {
        timelineButton.updateButton(title: title, image: AppIcon.timeline, foreground: .white)
    }

    func setEmptyImageViewHidden(_ isHidden: Bool) {
        emptyImageView.isHidden = isHidden
    }

    func configureForAddRecord() {
        commentTextView.isEditable = true
        ratingView.setEditable(true)
        editButton.isHidden = true
        saveButton.isHidden = true
        cancelButton.isHidden = true
        timelineButton.isHidden = true
        deleteButton.isHidden = true
    }
}
