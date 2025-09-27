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
    
    private let bookmarkButton = {
        let button = UIButton()
        button.setImage(AppIcon.bookmark, for: .normal)
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
        
        return collectionView
    }()
    
    private lazy var dataSource = { [weak self] in
        guard let self else {
            return UICollectionViewDiffableDataSource<Section, ClimbRecord>(collectionView: UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())) { _, _, _ in
                return nil
            }
        }
        
        let registration = createRegistration()
        let dataSource = UICollectionViewDiffableDataSource<Section, ClimbRecord>(collectionView: self.recordCollectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
        }
        
        return dataSource
    }()
 
    // MARK: - Setups
    override func setupView() {
        backgroundColor = AppColor.background
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
    
    func setSearchBarBorder(isFirstResponder: Bool) {
        let color = isFirstResponder ? AppColor.focusRing : UIColor.clear
        searchBar.layer.borderColor = color.cgColor
    }
    
    func setGuideLabelText(_ text: String) {
        guideLabel.text = text
    }
    
    func setClimbRecords(items: [ClimbRecord]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ClimbRecord>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - CollectionView Helper
extension ClimbRecordListView {
    
    private enum Section: CaseIterable {
        case main
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(120))
        let item = NSCollectionLayoutItem(layoutSize: size)
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: AppSpacing.regular, bottom: 0, trailing: AppSpacing.regular)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func createRegistration() -> UICollectionView.CellRegistration<ClimbRecordCollectionViewCell, ClimbRecord> {
        return UICollectionView.CellRegistration<ClimbRecordCollectionViewCell, ClimbRecord> { [weak self] cell, indexPath, item in
            guard let self else { return }
            
            let isFirst = indexPath.item == 0
            let lastIndex = self.recordCollectionView.numberOfItems(inSection: indexPath.section) - 1
            let isLast =  indexPath.item == lastIndex
            
            cell.setUpRoadImageHidden(isFirst: isFirst)
            cell.setDownRoadImageHidden(isLast: isLast)
            cell.setRoadImages(row: indexPath.item)
            cell.setData(item)
        }
    }
}
