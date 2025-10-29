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

    // 검색 바
    let searchBar = CustomSearchBar()
    
    // 북마크만 표기 버튼
    let bookmarkButton = {
        let button = UIButton()
        button.tintColor = AppColor.primary
        return button
    }()
    
    // 북마크만, 산 개수 표기 레이블
    private let guideLabel = {
        let label = UILabel.create(color: AppColor.mossGreen, font: AppFont.body)
        label.textAlignment = .center
        return label
    }()
    
    // 기록 컬렉션 뷰
    lazy var recordCollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.keyboardDismissMode = .onDrag
        collectionView.register(cellClass: ClimbRecordCollectionViewCell.self)

        return collectionView
    }()
    
    // 결과 없을 때 레이블
    private let emptyStateLabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    private let emptyLabelAttributes = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.alignment = .center
        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .foregroundColor: AppColor.subText,
            .font: AppFont.titleS
        ]
        return attributes
    }()
 
    private func createLayout() -> UICollectionViewCompositionalLayout {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(140))
        let item = NSCollectionLayoutItem(layoutSize: size)
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: AppSpacing.regular, bottom: AppSpacing.regular, trailing: AppSpacing.regular)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // MARK: - Setups
    override func setupView() {
        backgroundColor = AppColor.background
        setSearchBarBorder(isFirstResponder: false)
        setBookmarkImage(isOnlyBookmarked: false)
    }
    
    override func setupHierarchy() {
        [searchBar, bookmarkButton, guideLabel, recordCollectionView, emptyStateLabel].forEach {
            addSubview($0)
        }
    }
    
    override func setupLayout() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(AppSpacing.small)
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

        emptyStateLabel.snp.makeConstraints { make in
            make.center.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(AppSpacing.regular)
        }
    }
}

// MARK: - Binding Methods
extension ClimbRecordListView {
    
    // 산 개수, 북마크만 레이블
    func setGuideLabelText(_ text: String) {
        guideLabel.text = text
    }
    
    // 기록 컬렉션 뷰 갱신, 스크롤 위로 올리기
    func reloadData() {
        recordCollectionView.reloadData()
        recordCollectionView.setContentOffset(.zero, animated: false)
    }

    // 기록 결과에 따른 Visibility
    func setEmptyStateHidden(_ isHidden: Bool) {
        emptyStateLabel.isHidden = isHidden
        recordCollectionView.isHidden = !isHidden
    }
    
    // 결과 없을 때 레이블 텍스트
    func setEmptyStateText(_ text: String) {
        emptyStateLabel.attributedText = NSAttributedString(string: text, attributes: emptyLabelAttributes)
    }
    
    // 북마크만 표기 여부에 따른 이미지
    func setBookmarkImage(isOnlyBookmarked: Bool) {
        bookmarkButton.setImage(isOnlyBookmarked ? AppIcon.bookmarkFill : AppIcon.bookmark, for: .normal)
    }
    
    // 북마크 토글에 따른 셀 Reload
    func toggleCellBookmarked(row: Int) {
        recordCollectionView.reloadItems(at: [IndexPath(item: row, section: 0)])
    }
    
    // 검색 상태에 따른 검색 바 테두리
    func setSearchBarBorder(isFirstResponder: Bool) {
        searchBar.setBorder(isFirstResponder)
    }
}
