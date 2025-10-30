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

    // 통계 컨테이너
    private let statsContainerView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = AppRadius.medium
        view.layer.borderColor = AppColor.border.cgColor
        view.layer.borderWidth = 1
        return view
    }()

    // 정복한 산 개수
    private let mountainCountItemView = {
        let view = ItemView(subtitle: "정복한 산")
        view.setTitleColor(color: AppColor.primary)
        return view
    }()

    // 등산 횟수
    private let climbCountItemView = {
        let view = ItemView(subtitle: "등산 횟수")
        view.setTitleColor(color: AppColor.primary)
        return view
    }()

    // 총 높이
    private let totalHeightItemView = {
        let view = ItemView(subtitle: "총 높이")
        view.setTitleColor(color: AppColor.primary)
        return view
    }()

    // 세로 구분선
    private lazy var leftDividerView = createVerticalDividerView()
    private lazy var rightDividerView = createVerticalDividerView()

    // 가로 구분선
    private let lineView = {
        let view = UIView()
        view.backgroundColor = AppColor.tertiaryText.withAlphaComponent(0.2)
        return view
    }()

    // 검색 바
    let searchBar = CustomSearchBar()
    
    // 북마크만 표기 버튼
    let bookmarkButton = {
        let button = UIButton()
        button.tintColor = AppColor.primary
        return button
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
    
    private func createVerticalDividerView() -> UIView {
        let view = UIView()
        view.backgroundColor = AppColor.border
        view.snp.makeConstraints { make in
            make.width.equalTo(1)
        }
        return view
    }
    
    // MARK: - Setups
    override func setupView() {
        backgroundColor = AppColor.background
        setSearchBarBorder(isFirstResponder: false)
        setBookmarkImage(isOnlyBookmarked: false)
        // TODO: 데이터 바인딩
        mountainCountItemView.setTitle(title: "12개")
        climbCountItemView.setTitle(title: "25회")
        totalHeightItemView.setTitle(title: "15,230m")
    }
    
    override func setupHierarchy() {
        [statsContainerView, lineView, searchBar, bookmarkButton, recordCollectionView, emptyStateLabel].forEach {
            addSubview($0)
        }

        [mountainCountItemView, climbCountItemView, totalHeightItemView, leftDividerView, rightDividerView].forEach {
            statsContainerView.addSubview($0)
        }
    }
    
    override func setupLayout() {

        statsContainerView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(AppSpacing.regular)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(AppSpacing.regular)
            make.height.equalTo(60)
        }

        mountainCountItemView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.verticalEdges.equalToSuperview().inset(AppSpacing.compact)
            make.width.equalTo(climbCountItemView)
        }

        leftDividerView.snp.makeConstraints { make in
            make.leading.equalTo(mountainCountItemView.snp.trailing)
            make.verticalEdges.equalToSuperview().inset(AppSpacing.compact)
        }

        climbCountItemView.snp.makeConstraints { make in
            make.leading.equalTo(leftDividerView.snp.trailing)
            make.verticalEdges.equalToSuperview().inset(AppSpacing.compact)
            make.width.equalTo(totalHeightItemView)
        }

        rightDividerView.snp.makeConstraints { make in
            make.leading.equalTo(climbCountItemView.snp.trailing)
            make.verticalEdges.equalToSuperview().inset(AppSpacing.compact)
        }

        totalHeightItemView.snp.makeConstraints { make in
            make.leading.equalTo(rightDividerView.snp.trailing)
            make.trailing.equalToSuperview()
            make.verticalEdges.equalToSuperview().inset(AppSpacing.compact)
        }

        lineView.snp.makeConstraints { make in
            make.top.equalTo(statsContainerView.snp.bottom).offset(AppSpacing.regular)
            make.height.equalTo(1)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(AppSpacing.regular)
        }
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(AppSpacing.regular)
            make.height.equalTo(40)
            make.leading.equalTo(safeAreaLayoutGuide).offset(AppSpacing.regular)
            make.trailing.equalTo(bookmarkButton.snp.leading)
        }
        
        bookmarkButton.snp.makeConstraints { make in
            make.verticalEdges.equalTo(searchBar)
            make.width.equalTo(bookmarkButton.snp.height)
            make.trailing.equalTo(safeAreaLayoutGuide).offset(-AppSpacing.regular)
        }

        recordCollectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(AppSpacing.small)
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
