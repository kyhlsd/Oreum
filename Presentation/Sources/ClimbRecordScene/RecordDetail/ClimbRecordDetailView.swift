//
//  ClimbRecordDetailView.swift
//  Presentation
//
//  Created by 김영훈 on 9/28/25.
//

import UIKit
import SnapKit

final class ClimbRecordDetailView: BaseView {
    
    private let scrollView = UIScrollView()
    
    private let stackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = AppSpacing.regular
        stackView.alignment = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: AppSpacing.regular, right: 0)
        return stackView
    }()
    
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
    
    private let reviewView = BoxView(title: "나의 후기")
    
    private let timelineButton = CustomButton(title: "타임라인 보기", image: AppIcon.timeline, foreground: .white, background: AppColor.primary)

    private let deleteButton = CustomButton(title: "기록 삭제", image: AppIcon.trash, foreground: AppColor.danger, background: AppColor.dangerText, hasBorder: true)
    
    private func createContainerView(contentView: UIView) -> UIView {
        let view = UIView()
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.regular)
            make.verticalEdges.equalToSuperview()
        }
        return view
    }
    
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
        scrollView.addSubview(stackView)
        
        stackView.addArrangedSubview(imageCollectionView)
        
        [recordView, reviewView, timelineButton, deleteButton].forEach {
            stackView.addArrangedSubview(createContainerView(contentView: $0))
        }
        
        addSubview(pageControl)
    }
    
    override func setupLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView.snp.width)
        }
        
        imageCollectionView.snp.makeConstraints { make in
            make.height.equalTo(imageCollectionView.snp.width).multipliedBy(0.75)
        }
        
        pageControl.snp.makeConstraints { make in
            make.bottom.equalTo(imageCollectionView).inset(AppSpacing.regular)
            make.centerX.equalTo(imageCollectionView)
        }
        
        recordView.snp.makeConstraints { make in
            make.height.equalTo(200)
        }
        
        reviewView.snp.makeConstraints { make in
            make.height.equalTo(200)
        }
        
        timelineButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
    }
}

// MARK: - Binding Methods
extension ClimbRecordDetailView {
    
    
}
