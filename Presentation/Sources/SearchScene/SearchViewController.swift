//
//  SearchViewController.swift
//  Presentation
//
//  Created by 김영훈 on 10/6/25.
//

import UIKit
import Combine
import Domain

final class SearchViewController: UIViewController, BaseViewController {

    var pushInfoVC: ((MountainInfo) -> Void)?

    let mainView = SearchView()
    let viewModel: SearchViewModel

    private var cancellables = Set<AnyCancellable>()
    private lazy var recentSearchDataSource = createRecentSearchDataSource()
    private lazy var resultDataSource = createResultDataSource()

    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    private let searchTextSubject = PassthroughSubject<String, Never>()
    private let recentSearchTappedSubject = PassthroughSubject<String, Never>()
    private let deleteRecentSearchSubject = PassthroughSubject<String, Never>()
    private let clearAllRecentSearchesSubject = PassthroughSubject<Void, Never>()

    init(viewModel: SearchViewModel) {
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

        setupNavItem()
        setupDelegates()
        bind()

        viewDidLoadSubject.send(())
    }

    func bind() {
        let input = SearchViewModel.Input(
            viewDidLoad: viewDidLoadSubject.eraseToAnyPublisher(),
            searchText: searchTextSubject.eraseToAnyPublisher(),
            recentSearchTapped: recentSearchTappedSubject.eraseToAnyPublisher(),
            deleteRecentSearch: deleteRecentSearchSubject.eraseToAnyPublisher(),
            clearAllRecentSearches: clearAllRecentSearchesSubject.eraseToAnyPublisher()
        )

        mainView.clearAllButton.tap
            .sink { [weak self] in
                self?.clearAllRecentSearchesSubject.send(())
            }
            .store(in: &cancellables)

        let output = viewModel.transform(input: input)

        output.recentSearches
            .sink { [weak self] searches in
                self?.applyRecentSearchSnapshot(searches: searches)
                self?.mainView.showRecentSearchEmptyState(searches.isEmpty)
            }
            .store(in: &cancellables)

        output.searchResults
            .sink { [weak self] results in
                self?.applyResultSnapshot(results: results)
                self?.mainView.showEmptyState(results.isEmpty)
            }
            .store(in: &cancellables)

        output.errorMessage
            .sink { errorMessage in
                print(errorMessage)
            }
            .store(in: &cancellables)
    }

    private func setupNavItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: NavTitleLabel(title: "검색"))
        navigationItem.backButtonTitle = " "
    }

    private func setupDelegates() {
        mainView.searchBar.delegate = self
        mainView.recentSearchCollectionView.delegate = self
        mainView.resultCollectionView.delegate = self
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

// MARK: - CollectionView SubMethods
extension SearchViewController {

    private enum Section: CaseIterable {
        case main
    }

    private func createRecentSearchDataSource() -> UICollectionViewDiffableDataSource<Section, String> {
        let registration = UICollectionView.CellRegistration<RecentSearchCell, String> { [weak self] cell, indexPath, item in
            cell.configure(with: item)
            cell.deleteButtonTapped = {
                self?.deleteRecentSearchSubject.send(item)
            }
        }
        return UICollectionViewDiffableDataSource<Section, String>(collectionView: mainView.recentSearchCollectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
        }
    }

    private func createResultDataSource() -> UICollectionViewDiffableDataSource<Section, MountainInfo> {
        let registration = UICollectionView.CellRegistration<MountainInfoCollectionViewCell, MountainInfo> { cell, indexPath, item in
            cell.configure(with: item)
        }
        return UICollectionViewDiffableDataSource<Section, MountainInfo>(collectionView: mainView.resultCollectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
        }
    }

    private func applyRecentSearchSnapshot(searches: [String]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(searches)
        recentSearchDataSource.apply(snapshot, animatingDifferences: true)
    }

    private func applyResultSnapshot(results: [MountainInfo]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MountainInfo>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(results)
        resultDataSource.apply(snapshot, animatingDifferences: true)
    }
    
}

// MARK: - UICollectionViewDelegate
extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == mainView.recentSearchCollectionView {
            guard let search = recentSearchDataSource.itemIdentifier(for: indexPath) else { return }
            mainView.searchBar.text = search
            recentSearchTappedSubject.send(search)
        } else if collectionView == mainView.resultCollectionView {
            guard let mountainInfo = resultDataSource.itemIdentifier(for: indexPath) else { return }
            pushInfoVC?(mountainInfo)
        }
    }
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        mainView.setSearchBarBorder(isFirstResponder: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        mainView.setSearchBarBorder(isFirstResponder: false)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchTextSubject.send(searchBar.text ?? "")
    }
}

// MARK: - RecentSearchCell
final class RecentSearchCell: UICollectionViewCell {

    var deleteButtonTapped: (() -> Void)?

    private let containerView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = AppRadius.radius
        view.layer.borderWidth = 1
        view.layer.borderColor = AppColor.border.cgColor
        view.clipsToBounds = true
        return view
    }()

    private let label = UILabel.create(color: AppColor.primaryText, font: AppFont.tag)

    private lazy var deleteButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .regular)
        button.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        button.tintColor = AppColor.subText
        button.addTarget(self, action: #selector(deleteButtonAction), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        contentView.addSubview(containerView)
        [label, deleteButton].forEach {
            containerView.addSubview($0)
        }

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        label.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(AppSpacing.small)
            make.leading.equalToSuperview().inset(AppSpacing.compact)
        }

        deleteButton.snp.makeConstraints { make in
            make.leading.equalTo(label.snp.trailing).offset(AppSpacing.small)
            make.trailing.equalToSuperview().inset(AppSpacing.small)
            make.centerY.equalToSuperview()
            make.size.equalTo(16)
        }
    }

    func configure(with text: String) {
        label.text = text
    }

    @objc private func deleteButtonAction() {
        deleteButtonTapped?()
    }
}
