//
//  SearchView.swift
//  Presentation
//
//  Created by 김영훈 on 10/6/25.
//

import UIKit
import SnapKit

final class SearchView: BaseView {

    // 검색 바
    let searchBar = CustomSearchBar()
    
    // 최근 검색어 레이블
    private let recentSearchTitleLabel = UILabel.create("최근 검색어", color: AppColor.primaryText, font: AppFont.titleS)
    // 모두 지우기 버튼
    let clearAllButton = {
        let button = UIButton()
        button.setTitle("모두 지우기", for: .normal)
        button.setTitleColor(AppColor.subText, for: .normal)
        button.titleLabel?.font = AppFont.description
        return button
    }()
    // 최근 검색어 컬렉션뷰
    let recentSearchCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: 100, height: 32)
        layout.minimumInteritemSpacing = AppSpacing.small

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    // 최근 검색어 없음 레이블
    let recentSearchEmptyLabel = {
        let label = UILabel.create("최근 검색어가 없습니다", color: AppColor.subText, font: AppFont.body)
        label.isHidden = true
        return label
    }()

    // 검색 결과 레이블
    private let resultTitleLabel = UILabel.create("검색 결과", color: AppColor.primaryText, font: AppFont.titleS)
    // 검색 결과 컬렉션뷰
    lazy var resultCollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.keyboardDismissMode = .onDrag
        return collectionView
    }()
    // 검색 결과 없음 레이블
    let searchedEmptyLabel = {
        let label = UILabel.create("검색 결과가 없습니다", color: AppColor.subText, font: AppFont.body)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    // 로딩 인디케이터
    let loadingIndicator = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = AppColor.primaryText
        return indicator
    }()

    private func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = AppSpacing.small
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: AppSpacing.regular, bottom: AppSpacing.regular, trailing: AppSpacing.regular)

        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // MARK: - Setups

    override func setupView() {
        backgroundColor = AppColor.background
        searchBar.setBorder(false)
    }

    override func setupHierarchy() {
        [searchBar, recentSearchTitleLabel, clearAllButton, recentSearchCollectionView, recentSearchEmptyLabel, resultTitleLabel, resultCollectionView, searchedEmptyLabel, loadingIndicator].forEach {
            addSubview($0)
        }
    }

    override func setupLayout() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(AppSpacing.small)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.regular)
            make.height.equalTo(40)
        }

        recentSearchTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(AppSpacing.regular)
            make.leading.equalToSuperview().inset(AppSpacing.regular)
        }

        clearAllButton.snp.makeConstraints { make in
            make.lastBaseline.equalTo(recentSearchTitleLabel)
            make.trailing.equalToSuperview().inset(AppSpacing.regular)
        }

        recentSearchCollectionView.snp.makeConstraints { make in
            make.top.equalTo(recentSearchTitleLabel.snp.bottom).offset(AppSpacing.compact)
            make.horizontalEdges.equalToSuperview().inset(AppSpacing.regular)
            make.height.equalTo(40)
        }

        recentSearchEmptyLabel.snp.makeConstraints { make in
            make.center.equalTo(recentSearchCollectionView)
        }

        resultTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(recentSearchCollectionView.snp.bottom).offset(AppSpacing.regular)
            make.leading.equalToSuperview().inset(AppSpacing.regular)
        }

        resultCollectionView.snp.makeConstraints { make in
            make.top.equalTo(resultTitleLabel.snp.bottom).offset(AppSpacing.compact)
            make.horizontalEdges.bottom.equalTo(safeAreaLayoutGuide)
        }

        searchedEmptyLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(resultCollectionView)
        }

        loadingIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(resultCollectionView)
        }
    }
}

// MARK: - Binding Methods
extension SearchView {
    // 검색 결과 없음 표기
    func showSearchedEmptyState(_ show: Bool) {
        searchedEmptyLabel.isHidden = !show
        resultCollectionView.isHidden = show
    }
    // 최근 검색어 없음 표기
    func showRecentSearchEmptyState(_ show: Bool) {
        recentSearchEmptyLabel.isHidden = !show
        recentSearchCollectionView.isHidden = show
    }
    // 검색 바 테두리
    func setSearchBarBorder(isFirstResponder: Bool) {
        searchBar.setBorder(isFirstResponder)
    }
    // 로딩 인디케이터
    func setLoadingState(_ isLoading: Bool) {
        if isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }
}
