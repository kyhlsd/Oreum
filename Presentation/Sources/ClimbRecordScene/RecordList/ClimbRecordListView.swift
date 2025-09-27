//
//  ClimbRecordListView.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit
import Domain
import SnapKit

final class ClimbRecordListView: BaseView {
    
    private var climbRecordList = [ClimbRecord]()
    
    let searchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "산 이름 검색하세요"
        searchBar.searchTextField.font = AppFont.input
        searchBar.searchTextField.textColor = AppColor.inputText
        searchBar.searchTextField.leftView?.tintColor = AppColor.mossGreen
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.subviews.first?.isHidden = true
        searchBar.layer.borderWidth = 2.0
        searchBar.layer.cornerRadius = AppRadius.radius
        searchBar.returnKeyType = .search
        return searchBar
    }()
    
    let bookmarkButton = {
        let button = UIButton()
        button.tintColor = AppColor.primary
        return button
    }()
    
    private let guideLabel = {
        let label = UILabel.create(color: AppColor.mossGreen, font: AppFont.description)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var recordCollectionView = { [weak self] in
        guard let self else {
            return UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        }
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.keyboardDismissMode = .onDrag
        collectionView.register(cellClass: ClimbRecordCollectionViewCell.self)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        return collectionView
    }()
 
    // MARK: - Setups
    override func setupView() {
        backgroundColor = AppColor.background
        setSearchBarBorder(isFirstResponder: false)
        searchBar.delegate = self
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
    
    func setClimbRecords(items: [ClimbRecord]) {
        climbRecordList = items
        recordCollectionView.reloadData()
    }
    
    func setBookmarkImage(isOnlyBookmarked: Bool) {
        if isOnlyBookmarked {
            bookmarkButton.setImage(AppIcon.bookmarkFill, for: .normal)
        } else {
            bookmarkButton.setImage(AppIcon.bookmark, for: .normal)
        }
    }
}

// MARK: - CollectionView
extension ClimbRecordListView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return climbRecordList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellClass: ClimbRecordCollectionViewCell.self)
        
        cell.setImages(row: indexPath.item, total: climbRecordList.count)
        cell.setData(climbRecordList[indexPath.item])
        
        return cell
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(120))
        let item = NSCollectionLayoutItem(layoutSize: size)
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: AppSpacing.regular, bottom: 0, trailing: AppSpacing.regular)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: SearchBar
extension ClimbRecordListView: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        setSearchBarBorder(isFirstResponder: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        setSearchBarBorder(isFirstResponder: false)
    }
    
    private func setSearchBarBorder(isFirstResponder: Bool) {
        let color = isFirstResponder ? AppColor.focusRing : UIColor.clear
        searchBar.layer.borderColor = color.cgColor
    }
}
