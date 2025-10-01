//
//  ClimbRecordListViewController.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit
import Combine
import Domain

final class ClimbRecordListViewController: UIViewController {

    var pushVC: ((ClimbRecord) -> Void)?
    
    private let mainView = ClimbRecordListView()
    let viewModel: ClimbRecordListViewModel
    private var cancellables = Set<AnyCancellable>()
    
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
    
    private func bind() {
        let input = ClimbRecordListViewModel.Input(
            viewDidLoad: Just(()).eraseToAnyPublisher(),
            searchText: mainView.searchBar.textDidChange,
            bookmarkButtonTapped: mainView.bookmarkButton.tap,
            cellBookmarkButtonTapped: mainView.cellBookmarkTapSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        
        output.reloadData
            .sink { [weak self] in
                self?.mainView.reloadData()
            }
            .store(in: &cancellables)
        
        output.guideText
            .sink { [weak self] text in
                self?.mainView.setGuideLabelText(text)
            }
            .store(in: &cancellables)
        
        output.isOnlyBookmarked
            .sink { [weak self] isOnlyBookmarked in
                self?.mainView.setBookmarkImage(isOnlyBookmarked: isOnlyBookmarked)
            }
            .store(in: &cancellables)
        
        output.bookmarkToggled
            .sink { [weak self] row in
                self?.mainView.toggleCellBookmarked(row: row)
            }
            .store(in: &cancellables)
        
        output.errorMessage
            .sink { errorMessage in
               print(errorMessage)
            }
            .store(in: &cancellables)
    }

    private func setupNavItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: NavTitleLabel(title: "나의 등산 기록"))
        navigationItem.backButtonTitle = " "
    }
    
    private func setupDelegates() {
        mainView.searchBar.delegate = self
        
        mainView.recordCollectionView.delegate = self
        mainView.recordCollectionView.dataSource = self
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
        
        cell.setImages(row: indexPath.item, total: viewModel.climbRecordList.count)
        cell.setData(viewModel.climbRecordList[indexPath.item])
        cell.cellBookmarkTapSubject = mainView.cellBookmarkTapSubject
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let climbRecord = viewModel.climbRecordList[indexPath.item]
        pushVC?(climbRecord)
    }
}
