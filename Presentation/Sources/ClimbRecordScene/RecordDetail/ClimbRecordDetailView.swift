//
//  ClimbRecordDetailView.swift
//  Presentation
//
//  Created by 김영훈 on 9/28/25.
//

import UIKit
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
        pageControl.backgroundStyle = .prominent
        pageControl.hidesForSinglePage = true
        return pageControl
    }()
    
    private let recordView = BoxView(title: "기록")
    
    private let dateView = ItemView(icon: AppIcon.date, title: "24년 9월 21일", subtitle: "날짜")
    private let timeView = ItemView(icon: AppIcon.clock, title: "4시간 35분", subtitle: "소요시간")
    private let stepView = ItemView(icon: AppIcon.footprints, title: "12,345", subtitle: "걸음수")
    private let heightView = ItemView(icon: AppIcon.mountain, title: "2,744m", subtitle: "높이")
    
    private let reviewView = BoxView(title: "나의 후기")
    let commentTextView = {
        let textView = UITextView(usingTextLayoutManager: false)
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        textView.typingAttributes = [
            .paragraphStyle: paragraphStyle,
            .font: AppFont.body,
            .foregroundColor: AppColor.subText
        ]
        textView.isScrollEnabled = false
        return textView
    }()
    
    private let timelineButton = CustomButton(title: "타임라인 보기", image: AppIcon.timeline, foreground: .white, background: AppColor.primary)

    private let deleteButton = CustomButton(title: "기록 삭제", image: AppIcon.trash, foreground: AppColor.danger, background: AppColor.dangerText, hasBorder: true)
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: size)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .zero
        section.orthogonalScrollingBehavior = .paging
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // MARK: - Setups
    override func setupView() {
        backgroundColor = AppColor.background
    }
    
    override func setupHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [imageCollectionView, pageControl, recordView, reviewView, timelineButton, deleteButton].forEach {
            contentView.addSubview($0)
        }
        
        [dateView, timeView, stepView, heightView].forEach {
            recordView.addSubview($0)
        }
        
        reviewView.addSubview(commentTextView)
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
        
        pageControl.snp.makeConstraints { make in
            make.bottom.equalTo(imageCollectionView).inset(AppSpacing.regular)
            make.centerX.equalTo(imageCollectionView)
        }
        
        recordView.snp.makeConstraints { make in
            make.top.equalTo(imageCollectionView.snp.bottom).offset(AppSpacing.regular)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.regular)
        }
        
        let itemHeight = 48
        
        dateView.snp.makeConstraints { make in
            make.top.equalTo(recordView.lineView.snp.bottom).offset(AppSpacing.compact)
            make.leading.equalToSuperview().offset(AppSpacing.compact)
            make.trailing.equalTo(recordView.snp.centerX).inset(AppSpacing.compact / 2)
            make.height.equalTo(itemHeight)
        }
        
        timeView.snp.makeConstraints { make in
            make.top.equalTo(recordView.lineView.snp.bottom).offset(AppSpacing.compact)
            make.leading.equalTo(recordView.snp.centerX).offset(AppSpacing.compact / 2)
            make.trailing.equalToSuperview().inset(AppSpacing.compact)
            make.height.equalTo(itemHeight)
        }
        
        stepView.snp.makeConstraints { make in
            make.top.equalTo(dateView.snp.bottom).offset(AppSpacing.compact)
            make.leading.equalToSuperview().offset(AppSpacing.compact)
            make.trailing.equalTo(recordView.snp.centerX).inset(AppSpacing.compact / 2)
            make.height.equalTo(itemHeight)
            make.bottom.equalToSuperview().inset(AppSpacing.compact)
        }
        
        heightView.snp.makeConstraints { make in
            make.top.equalTo(dateView.snp.bottom).offset(AppSpacing.compact)
            make.leading.equalTo(recordView.snp.centerX).offset(AppSpacing.compact / 2)
            make.trailing.equalToSuperview().inset(AppSpacing.compact)
            make.height.equalTo(itemHeight)
            make.bottom.equalToSuperview().inset(AppSpacing.compact)
        }
        
        reviewView.snp.makeConstraints { make in
            make.top.equalTo(recordView.snp.bottom).offset(AppSpacing.regular)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.regular)
        }
        
        commentTextView.snp.makeConstraints { make in
            make.top.equalTo(reviewView.lineView.snp.bottom).offset(AppSpacing.compact)
            make.horizontalEdges.bottom.equalToSuperview().inset(AppSpacing.compact)
            make.height.greaterThanOrEqualTo(20)
            make.height.lessThanOrEqualTo(144)
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
}
