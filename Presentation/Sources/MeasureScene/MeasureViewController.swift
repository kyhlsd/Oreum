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
        let didBecomeActive = NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .map { _ in () }
            .eraseToAnyPublisher()

        let input = MeasureViewModel.Input(
            checkPermissionTrigger: Just(()).eraseToAnyPublisher(),
            checkTrackingStatusTrigger: Just(()).eraseToAnyPublisher(),
            searchTrigger: searchTriggerSubject.eraseToAnyPublisher(),
            selectMountain: selectMountainSubject.eraseToAnyPublisher(),
            cancelMountain: mainView.cancelButton.tap.eraseToAnyPublisher(),
            startMeasuring: mainView.startButton.tap.eraseToAnyPublisher(),
            cancelMeasuring: mainView.cancelMeasuringButton.tap.eraseToAnyPublisher(),
            stopMeasuring: mainView.stopButton.tap.eraseToAnyPublisher(),
            didBecomeActive: didBecomeActive
        )

        let output = viewModel.transform(input: input)

        // Permission check가 먼저 완료된 후 tracking status 체크
        output.permissionAuthorized
            .sink { [weak self] authorized in
                print("✅ Permission authorized: \(authorized)")
                self?.mainView.updatePermissionRequiredViewIsHidden(authorized)
            }
            .store(in: &cancellables)

        // updateMeasuringStateTrigger는 이미 trackingStatus와 병합된 상태
        Publishers.CombineLatest(output.permissionAuthorized, output.updateMeasuringStateTrigger)
            .sink { [weak self] authorized, isMeasuring in
                print("🔍 ViewController - authorized: \(authorized), isMeasuring: \(isMeasuring)")
                guard authorized else { return }
                print("✅ Measuring state: \(isMeasuring)")
                self?.mainView.updateMeasuringState(isMeasuring: isMeasuring)
                self?.setNavItem(isMeasuring: isMeasuring)
            }
            .store(in: &cancellables)

        output.searchResults
            .sink { [weak self] mountains in
                self?.applySnapshot(mountains: mountains)
            }
            .store(in: &cancellables)

        output.updateMountainLabelsTrigger
            .sink { [weak self] (name, address) in
                self?.mainView.updateMountainLabelTexts(name: name, address: address)
            }
            .store(in: &cancellables)

        output.clearMountainSelectionTrigger
            .sink { [weak self] in
                self?.mainView.clearMountainSelection()
            }
            .store(in: &cancellables)
        
        output.updateStartButtonIsEnabledTrigger
            .sink { [weak self] isEnabled in
                self?.mainView.updateStartButtonIsEnabled(isEnabled)
            }
            .store(in: &cancellables)
        
        output.updateSearchResultsOverlayIsHiddenTrigger
            .sink { [weak self] isHidden in
                self?.mainView.updateSearchResultsOverlayIsHidden(isHidden)
            }
            .store(in: &cancellables)

        output.updateSearchResultsTrigger
            .sink { [weak self] count in
                self?.mainView.updateSearchResults(count: count)
            }
            .store(in: &cancellables)

        output.clearSearchBarTrigger
            .sink { [weak self] in
                self?.mainView.clearSearchBar()
            }
            .store(in: &cancellables)

        output.updateActivityDataTrigger
            .sink { [weak self] time, distance, steps in
                print(time, distance, steps)
                self?.mainView.updateMeasuringData(time: time, distance: distance, steps: steps)
            }
            .store(in: &cancellables)

        mainView.openSettingsButton.tap
            .sink {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            .store(in: &cancellables)
    }

    private func setNavItem(isMeasuring: Bool) {
        navigationItem.leftBarButtonItem?.isHidden = isMeasuring
        navigationItem.title = isMeasuring ? "측정 중" : nil
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
        mainView.updateSearchBarBorder(isFirstResponder: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        mainView.updateSearchBarBorder(isFirstResponder: false)
        mainView.updateSearchResultsOverlayIsHidden(true)
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
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
