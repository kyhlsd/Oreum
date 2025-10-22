//
//  AddClimbRecordViewController.swift
//  Presentation
//
//  Created by 김영훈 on 10/2/25.
//

import UIKit
import Combine
import Domain

final class AddClimbRecordViewController: UIViewController, BaseViewController {

    var dismissVC: (() -> Void)?
    var pushVC: ((ClimbRecord) -> Void)?

    let mainView = AddClimbRecordView()
    let viewModel: AddClimbRecordViewModel
    private var cancellables = Set<AnyCancellable>()
    private lazy var dataSource = createDataSource()

    private let searchTriggerSubject = PassthroughSubject<String, Never>()
    private let mountainSelectedSubject = PassthroughSubject<Mountain, Never>()
    private let dateChangedSubject = PassthroughSubject<Date, Never>()

    init(viewModel: AddClimbRecordViewModel) {
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
        let input = AddClimbRecordViewModel.Input(
            searchTrigger: searchTriggerSubject.eraseToAnyPublisher(),
            mountainSelected: mountainSelectedSubject.eraseToAnyPublisher(),
            cancelMountain: mainView.cancelButton.tap,
            dateChanged: dateChangedSubject.eraseToAnyPublisher(),
            nextButtonTapped: mainView.nextButton.tap
        )

        let output = viewModel.transform(input: input)

        // 검색 결과 반영, 스크롤 위로 올리기
        output.searchResults
            .sink { [weak self] mountains in
                self?.applySnapshot(mountains: mountains)
                self?.mainView.searchResultsTableView.setContentOffset(.zero, animated: false)
            }
            .store(in: &cancellables)

        // 산 정보 반영
        output.updateMountainLabelsTrigger
            .sink { [weak self] (name, address) in
                self?.mainView.updateMountainLabelTexts(name: name, address: address)
            }
            .store(in: &cancellables)

        // 산 선택 취소 반영
        output.clearMountainSelectionTrigger
            .sink { [weak self] in
                self?.mainView.clearMountainSelection()
            }
            .store(in: &cancellables)

        // 검색 뷰 오버레이 Visibility
        output.updateSearchResultsOverlayIsHiddenTrigger
            .sink { [weak self] isHidden in
                self?.mainView.updateSearchResultsOverlayIsHidden(isHidden)
            }
            .store(in: &cancellables)

        // 검색 결과 업데이트
        output.updateSearchResultsTrigger
            .sink { [weak self] count in
                self?.mainView.updateSearchResults(count: count)
            }
            .store(in: &cancellables)

        // 검색 바 초기화
        output.clearSearchBarTrigger
            .sink { [weak self] in
                self?.mainView.clearSearchBar()
            }
            .store(in: &cancellables)

        // 다음 버튼 활성화
        output.updateNextButtonIsEnabledTrigger
            .sink { [weak self] isEnabled in
                self?.mainView.setNextButtonEnabled(isEnabled)
            }
            .store(in: &cancellables)

        // DetailVC push
        output.pushDetailVC
            .sink { [weak self] climbRecord in
                self?.pushVC?(climbRecord)
            }
            .store(in: &cancellables)

        // ErrorAlert
        output.errorMessage
            .sink { [weak self] (title, message) in
                self?.presentDefaultAlert(title: title, message: message)
            }
            .store(in: &cancellables)
        
        mainView.datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
    }

    private func setupNavItem() {
        navigationItem.title = "등산 기록 추가"
        if #unavailable(iOS 26.0) {
            navigationItem.backButtonTitle = " "
        }
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelButtonTapped))
        cancelButton.tintColor = AppColor.primary
        navigationItem.leftBarButtonItem = cancelButton
    }

    private func setupDelegates() {
        mainView.searchBar.delegate = self
        mainView.searchResultsTableView.delegate = self
    }
    
    @objc private func cancelButtonTapped() {
        dismissVC?()
    }

    @objc private func datePickerValueChanged() {
        dateChangedSubject.send(mainView.datePicker.date)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

// MARK: - UISearchBarDelegate
extension AddClimbRecordViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        mainView.setSearchBarBorder(isFirstResponder: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        mainView.setSearchBarBorder(isFirstResponder: false)
        mainView.updateSearchResultsOverlayIsHidden(true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        searchTriggerSubject.send(searchText)
    }
}

// MARK: - UITableView SubMethods
extension AddClimbRecordViewController: UITableViewDelegate {

    private enum Section {
        case main
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let mountain = dataSource.itemIdentifier(for: indexPath) else { return }
        view.endEditing(true)
        mountainSelectedSubject.send(mountain)
    }

    private func createDataSource() -> UITableViewDiffableDataSource<Section, Mountain> {
        let dataSource = UITableViewDiffableDataSource<Section, Mountain>(
            tableView: mainView.searchResultsTableView
        ) { tableView, indexPath, mountain in
            let cell = tableView.dequeueReusableCell(for: indexPath, cellClass: SearchMountainTableViewCell.self)
            cell.setData(mountain: mountain)
            return cell
        }
        return dataSource
    }

    private func applySnapshot(mountains: [Mountain]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Mountain>()
        snapshot.appendSections([.main])
        snapshot.appendItems(mountains)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
