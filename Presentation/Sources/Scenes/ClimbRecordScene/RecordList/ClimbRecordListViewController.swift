//
//  ClimbRecordListViewController.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit
import Combine
import Domain

final class ClimbRecordListViewController: UIViewController, BaseViewController {

    var pushDetailVC: ((ClimbRecord) -> Void)?
    var presentAddVC: (() -> Void)?

    let mainView = ClimbRecordListView()
    let viewModel: ClimbRecordListViewModel
    private var cancellables = Set<AnyCancellable>()
    private let cellBookmarkTapSubject = PassthroughSubject<String, Never>()
    
    init(viewModel: ClimbRecordListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
        setupNavItem()
        setupDelegates()
    }
    
    func bind() {

        let input = ClimbRecordListViewModel.Input(
            viewDidLoad: Just(()).eraseToAnyPublisher(),
            searchText: mainView.searchBar.textDidChange,
            bookmarkButtonTapped: mainView.bookmarkButton.tap,
            cellBookmarkButtonTapped: cellBookmarkTapSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        
        // 기록 리스트 뷰 Reload
        output.reloadData
            .sink { [weak self] in
                guard let self else { return }
                self.mainView.reloadData()
                self.mainView.setEmptyStateHidden(!self.viewModel.climbRecordList.isEmpty)
            }
            .store(in: &cancellables)
        
        // 산 개수, 북마크만 레이블 텍스트
        output.guideText
            .sink { [weak self] text in
                self?.mainView.setGuideLabelText(text)
            }
            .store(in: &cancellables)
        
        // 북마크만 표기에 따른 이미지
        output.isOnlyBookmarked
            .sink { [weak self] isOnlyBookmarked in
                self?.mainView.setBookmarkImage(isOnlyBookmarked: isOnlyBookmarked)
            }
            .store(in: &cancellables)
        
        // 북마크 토글
        output.bookmarkToggled
            .sink { [weak self] row in
                self?.mainView.toggleCellBookmarked(row: row)
            }
            .store(in: &cancellables)

        // 기록 결과 유무에 따른 레이블 표기
        output.emptyStateText
            .sink { [weak self] text in
                self?.mainView.setEmptyStateText(text)
            }
            .store(in: &cancellables)
        
        // 에러 Alert
        output.errorMessage
            .sink { [weak self] (title, message) in
                self?.presentDefaultAlert(title: title, message: message)
            }
            .store(in: &cancellables)
    }

    private func setupNavItem() {
        if #available(iOS 26.0, *) {
            navigationItem.attributedTitle = AppAppearance.getMainTitle(title: "나의 등산 기록")
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: NavTitleLabel(title: "나의 등산 기록"))
            navigationItem.backButtonTitle = " "
        }
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        addButton.tintColor = AppColor.primary
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func setupDelegates() {
        mainView.searchBar.delegate = self
        
        mainView.recordCollectionView.delegate = self
        mainView.recordCollectionView.dataSource = self
    }
    
    @objc private func addButtonTapped() {
        presentAddVC?()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

// MARK: - UISearchBarDelegate
extension ClimbRecordListViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        mainView.setSearchBarBorder(isFirstResponder: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        mainView.setSearchBarBorder(isFirstResponder: false)
    }
}

// MARK: - UICollectionViewDelegate & DataSource
extension ClimbRecordListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.climbRecordList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellClass: ClimbRecordCollectionViewCell.self)

        let climbRecord = viewModel.climbRecordList[indexPath.item]

        let firstRecordOfMountain = viewModel.climbRecordList
            .filter { $0.mountain.address == climbRecord.mountain.address }
            .min { $0.climbDate < $1.climbDate }
        let isFirstVisit = firstRecordOfMountain?.id == climbRecord.id

        cell.setImages(row: indexPath.item, total: viewModel.climbRecordList.count)
        cell.setData(climbRecord, isFirstVisit: isFirstVisit)
        cell.bookmarkTapped = { [weak self] recordId in
            self?.cellBookmarkTapSubject.send(recordId)
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let climbRecord = viewModel.climbRecordList[indexPath.item]
        pushDetailVC?(climbRecord)
    }
}
