//
//  MeasureViewController.swift
//  Presentation
//
//  Created by 김영훈 on 9/30/25.
//

import UIKit
import Combine
import Domain

final class MeasureViewController: UIViewController, BaseViewController {

    let mainView = MeasureView()
    let viewModel: MeasureViewModel

    private var cancellables = Set<AnyCancellable>()
    private lazy var dataSource = createDataSource()
    
    private let searchTriggerSubject = PassthroughSubject<String, Never>()
    private let selectMountainSubject = PassthroughSubject<MountainInfo, Never>()

    init(viewModel: MeasureViewModel) {
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
        let input = MeasureViewModel.Input(
            searchTrigger: searchTriggerSubject.eraseToAnyPublisher(),
            selectMountain: selectMountainSubject.eraseToAnyPublisher()
        )

        let output = viewModel.transform(input: input)

        output.searchResults
            .sink { [weak self] mountains in
                self?.applySnapshot(mountains: mountains)
            }
            .store(in: &cancellables)

        output.setMountainLabelTrigger
            .sink { [weak self] (name, address) in
                self?.mainView.setMountainLabelTexts(name: name, address: address)
            }
            .store(in: &cancellables)
        
        output.setMountainBoxIsHiddenTrigger
            .sink { [weak self] isHidden in
                self?.mainView.setMountainBoxIsHidden(isHidden)
            }
            .store(in: &cancellables)
        
        output.setStartButtonEnabledTrigger
            .sink { [weak self] isEnabled in
                self?.mainView.setStartButtonEnabled(isEnabled)
            }
            .store(in: &cancellables)
        
        output.setSearchResultsOverlayIsHiddenTrigger
            .sink { [weak self] isHidden in
                self?.mainView.setSearchResultsOverlayIsHidden(isHidden)
            }
            .store(in: &cancellables)
    }

    private func setNavItem(isMeasuring: Bool) {
        navigationItem.leftBarButtonItem?.isHidden = isMeasuring
        navigationItem.title = isMeasuring ? "측정 중" : " "
    }

    private func setupNavItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: NavTitleLabel(title: "측정"))
    }

    private func setupDelegates() {
        mainView.searchBar.delegate = self
        mainView.searchResultsTableView.delegate = self
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

// MARK: - UISearchBarDelegate
extension MeasureViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        mainView.setSearchBarBorder(isFirstResponder: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        mainView.setSearchBarBorder(isFirstResponder: false)
        mainView.setSearchResultsOverlayIsHidden(true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        searchTriggerSubject.send(searchText)
    }
    
}

// MARK: - UITableViewDelegate + SubMethods
extension MeasureViewController: UITableViewDelegate {

    private enum Section {
        case main
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let mountain = dataSource.itemIdentifier(for: indexPath) else { return }
        selectMountainSubject.send(mountain)
    }
    
    private func createDataSource() -> UITableViewDiffableDataSource<Section, MountainInfo> {
        let dataSource = UITableViewDiffableDataSource<Section, MountainInfo>(
            tableView: mainView.searchResultsTableView
        ) { tableView, indexPath, mountainInfo in
            let cell = tableView.dequeueReusableCell(for: indexPath, cellClass: SearchMountainTableViewCell.self)
            cell.setData(mountainInfo: mountainInfo)
            return cell
        }
        return dataSource
    }
    
    private func applySnapshot(mountains: [MountainInfo]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MountainInfo>()
        snapshot.appendSections([.main])
        snapshot.appendItems(mountains)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
