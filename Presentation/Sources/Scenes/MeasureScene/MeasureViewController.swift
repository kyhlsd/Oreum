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

    var showRecordDetail: ((ClimbRecord) -> Void)?

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

        let cancelMeasuringSubject = PassthroughSubject<Void, Never>()
        let stopMeasuringSubject = PassthroughSubject<Void, Never>()

        let input = MeasureViewModel.Input(
            checkPermissionTrigger: Just(()).eraseToAnyPublisher(),
            checkTrackingStatusTrigger: Just(()).eraseToAnyPublisher(),
            searchTrigger: searchTriggerSubject.eraseToAnyPublisher(),
            selectMountain: selectMountainSubject.eraseToAnyPublisher(),
            cancelMountain: mainView.cancelButton.tap,
            startMeasuring: mainView.startButton.tap,
            cancelMeasuring: cancelMeasuringSubject.eraseToAnyPublisher(),
            stopMeasuring: stopMeasuringSubject.eraseToAnyPublisher(),
            didBecomeActive: didBecomeActive
        )

        let output = viewModel.transform(input: input)

        // Permission check가 먼저 완료된 후 tracking status 체크
        output.permissionAuthorized
            .sink { [weak self] authorized in
                self?.mainView.updatePermissionRequiredViewIsHidden(authorized)
            }
            .store(in: &cancellables)

        output.authorizedMeasuringState
            .sink { [weak self] state in
                guard state.authorized else { return }
                self?.mainView.updateMeasuringState(isMeasuring: state.isMeasuring)
                self?.setNavItem(isMeasuring: state.isMeasuring)
            }
            .store(in: &cancellables)

        output.searchResults
            .sink { [weak self] mountains in
                self?.applySnapshot(mountains: mountains)
                self?.mainView.searchResultsTableView.setContentOffset(.zero, animated: false)
            }
            .store(in: &cancellables)

        output.updateMountainLabelsTrigger
            .sink { [weak self] (name, address) in
                self?.mainView.updateMountainLabelTexts(name: name, address: address)
            }
            .store(in: &cancellables)

        output.restoreMountainInfoTrigger
            .sink { [weak self] mountainInfo in
                if let (name, address) = mountainInfo {
                    self?.mainView.updateMountainLabelTexts(name: name, address: address)
                }
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

        mainView.cancelMeasuringButton.tap
            .sink { [weak self] in
                guard let self else { return }
                
                showCancelMeasuringAlert {
                    cancelMeasuringSubject.send()
                    self.showDefaultToast(message: "기록 측정을 취소했습니다")
                }
            }
            .store(in: &cancellables)

        mainView.stopButton.tap
            .sink { [weak self] in
                guard let self else { return }

                presentCancellableAlert(title: "측정 종료", message: "측정을 종료하시겠습니까?") {
                    stopMeasuringSubject.send()
                }
            }
            .store(in: &cancellables)

        output.savedClimbRecord
            .sink { [weak self] climbRecord in
                self?.showMeasureCompleteView(climbRecord: climbRecord)
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
    
    private func showMeasureCompleteView(climbRecord: ClimbRecord) {
        let completeView = MeasureCompleteView()
        completeView.alpha = 0
        view.addSubview(completeView)
        completeView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        completeView.addDetailButton.tap
            .sink { [weak self, weak completeView] in
                UIView.animate(withDuration: 0.3, animations: {
                    completeView?.alpha = 0
                }, completion: { [weak self] _ in
                    completeView?.removeFromSuperview()
                    self?.showRecordDetail?(climbRecord)
                })
            }
            .store(in: &cancellables)

        completeView.confirmButton.tap
            .sink { [weak completeView] in
                UIView.animate(withDuration: 0.3, animations: {
                    completeView?.alpha = 0
                }, completion: { _ in
                    completeView?.removeFromSuperview()
                })
            }
            .store(in: &cancellables)

        UIView.animate(withDuration: 0.3) {
            completeView.alpha = 1
        }
    }
    
    private func showCancelMeasuringAlert(completionHanlder: @escaping (() -> Void)) {
        let alert = UIAlertController(
            title: "측정 취소",
            message: "측정을 취소하시겠습니까?\n측정한 데이터는 저장되지 않습니다.",
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(title: "측정 취소", style: .destructive) { _ in
            completionHanlder()
        }

        let continueAction = UIAlertAction(title: "측정 계속하기", style: .cancel)

        alert.addAction(cancelAction)
        alert.addAction(continueAction)

        present(alert, animated: true)
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

// MARK: - UITableView SubMethods
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
            cell.setData(mountain: mountainInfo.toMountain())
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
