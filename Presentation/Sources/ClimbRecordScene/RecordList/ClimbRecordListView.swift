//
//  ClimbRecordListView.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit
import Combine
import SnapKit

final class ClimbRecordListView: BaseView {

    let cellBookmarkTapSubject = PassthroughSubject<String, Never>()
    
    let searchBar = CustomSearchBar()
    
    let bookmarkButton = {
        let button = UIButton()
        button.tintColor = AppColor.primary
        return button
    }()
    
    private let guideLabel = {
        let label = UILabel.create(color: AppColor.mossGreen, font: AppFont.body)
        label.textAlignment = .center
        return label
    }()
    
    lazy var recordCollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.keyboardDismissMode = .onDrag
        collectionView.register(cellClass: ClimbRecordCollectionViewCell.self)
        
        return collectionView
    }()
 
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(120))
        let item = NSCollectionLayoutItem(layoutSize: size)
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: AppSpacing.regular, bottom: 0, trailing: AppSpacing.regular)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // MARK: - Setups
    override func setupView() {
        backgroundColor = AppColor.background
        setSearchBarBorder(isFirstResponder: false)
        setBookmarkImage(isOnlyBookmarked: false)
    }
    
    override func setupHierarchy() {
        [searchBar, bookmarkButton, guideLabel, recordCollectionView].forEach {
            addSubview($0)
        }
    }
    
    override func setupLayout() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(40)
            make.leading.equalTo(safeAreaLayoutGuide).offset(AppSpacing.regular)
            make.trailing.equalTo(bookmarkButton.snp.leading)
        }
        
        bookmarkButton.snp.makeConstraints { make in
            make.verticalEdges.equalTo(searchBar)
            make.width.equalTo(bookmarkButton.snp.height)
            make.trailing.equalTo(safeAreaLayoutGuide).offset(-AppSpacing.regular)
        }
        
        guideLabel.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(AppSpacing.regular)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(AppSpacing.regular)
        }
        
        recordCollectionView.snp.makeConstraints { make in
            make.top.equalTo(guideLabel.snp.bottom).offset(AppSpacing.regular)
            make.horizontalEdges.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
}

// MARK: - Binding Methods
extension ClimbRecordListView {
    
    func setGuideLabelText(_ text: String) {
        guideLabel.text = text
    }
    
    func reloadData() {
        recordCollectionView.reloadData()
        if recordCollectionView.numberOfItems(inSection: 0) > 0 {
            recordCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }
    }
    
    func setBookmarkImage(isOnlyBookmarked: Bool) {
        bookmarkButton.setImage(isOnlyBookmarked ? AppIcon.bookmarkFill : AppIcon.bookmark, for: .normal)
    }
    
    func toggleCellBookmarked(row: Int) {
        recordCollectionView.reloadItems(at: [IndexPath(item: row, section: 0)])
    }
    
    func setSearchBarBorder(isFirstResponder: Bool) {
        searchBar.setBorder(isFirstResponder)
    }
}
