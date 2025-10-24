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

    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    private let searchTriggerSubject = PassthroughSubject<String, Never>()
    private let loadMoreTriggerSubject = PassthroughSubject<Void, Never>()
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
        
        viewDidLoadSubject.send(())
    }

    func bind() {
        // Active 상태가 됐을 떄
        let didBecomeActive = NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .map { _ in () }
            .eraseToAnyPublisher()

        let cancelMeasuringSubject = PassthroughSubject<Void, Never>()
        let stopMeasuringSubject = PassthroughSubject<Void, Never>()

        let input = MeasureViewModel.Input(
            viewDidLoad: viewDidLoadSubject.eraseToAnyPublisher(),
            searchTrigger: searchTriggerSubject.eraseToAnyPublisher(),
            loadMoreTrigger: loadMoreTriggerSubject.eraseToAnyPublisher(),
            selectMountain: selectMountainSubject.eraseToAnyPublisher(),
            cancelMountain: mainView.cancelButton.tap,
            startMeasuring: mainView.startButton.tap,
            cancelMeasuring: cancelMeasuringSubject.eraseToAnyPublisher(),
            stopMeasuring: stopMeasuringSubject.eraseToAnyPublisher(),
            didBecomeActive: didBecomeActive
        )

        let output = viewModel.transform(input: input)

        // 권한 및 측정 상태 업데이트
        output.authorizedMeasuringState
            .sink { [weak self] state in
                guard let self else { return }

                // 권한에 따라 권한 요청 뷰 표시/숨김
                mainView.updatePermissionRequiredViewIsHidden(state.authorized)

                // 권한이 있을 때만 측정 상태 UI 업데이트
                if state.authorized {
                    mainView.updateMeasuringState(isMeasuring: state.isMeasuring)
                    setNavItem(isMeasuring: state.isMeasuring)
                }
            }
            .store(in: &cancellables)

        // 산 검색 결과
        output.searchResults
            .sink { [weak self] mountains in
                self?.applySnapshot(mountains: mountains)
            }
            .store(in: &cancellables)

        // 새로운 검색 시 스크롤 위로 올리기
        searchTriggerSubject
            .sink { [weak self] _ in
                self?.mainView.searchResultsTableView.setContentOffset(.zero, animated: false)
            }
            .store(in: &cancellables)

        // 산 검색 오버레이 Visibility 설정
        output.updateSearchResultsOverlayIsHiddenTrigger
            .sink { [weak self] isHidden in
                self?.mainView.updateSearchResultsOverlayIsHidden(isHidden)
            }
            .store(in: &cancellables)
        
        // 산 검색 결과 높이 설정
        output.updateSearchResultsTrigger
            .sink { [weak self] count in
                self?.mainView.updateSearchResults(count: count)
            }
            .store(in: &cancellables)
        
        // 산 정보 레이블 업데이트
        output.updateMountainLabelsTrigger
            .sink { [weak self] (name, address) in
                self?.mainView.updateMountainLabelTexts(name: name, address: address)
            }
            .store(in: &cancellables)

        // 산 선택 취소
        output.clearMountainSelectionTrigger
            .sink { [weak self] in
                self?.mainView.clearMountainSelection()
            }
            .store(in: &cancellables)
        
        // 측정 시작 버튼 활성화
        output.updateStartButtonIsEnabledTrigger
            .sink { [weak self] isEnabled in
                self?.mainView.updateStartButtonIsEnabled(isEnabled)
            }
            .store(in: &cancellables)

        // 검색 바 초기화
        output.clearSearchBarTrigger
            .sink { [weak self] in
                self?.mainView.clearSearchBar()
            }
            .store(in: &cancellables)

        // Activity 데이터 업데이트
        output.updateActivityDataTrigger
            .sink { [weak self] time, distance, steps in
                self?.mainView.updateMeasuringData(time: time, distance: distance, steps: steps)
            }
            .store(in: &cancellables)

        // 권한 설정 열기
        mainView.openSettingsButton.tap
            .sink {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            .store(in: &cancellables)

        // 측정 취소 Alert
        mainView.cancelMeasuringButton.tap
            .sink { [weak self] in
                guard let self else { return }
                
                showCancelMeasuringAlert {
                    cancelMeasuringSubject.send()
                    self.showDefaultToast(message: "기록 측정을 취소했습니다")
                }
            }
            .store(in: &cancellables)

        // 측정 종료 Alert
        mainView.stopButton.tap
            .sink { [weak self] in
                guard let self else { return }

                presentCancellableAlert(title: "측정 종료", message: "측정을 종료하시겠습니까?") {
                    stopMeasuringSubject.send()
                }
            }
            .store(in: &cancellables)

        // 기록 저장 완료 시 후기 작성 뷰
        output.savedClimbRecord
            .sink { [weak self] climbRecord in
                self?.showMeasureCompleteView(climbRecord: climbRecord)
            }
            .store(in: &cancellables)
        
        // 에러 Alert
        output.errorMessage
            .sink { [weak self] (title, message) in
                self?.presentDefaultAlert(title: title, message: message)
            }
            .store(in: &cancellables)

        // 로딩 인디케이터
        output.isLoading
            .sink { [weak self] isLoading in
                self?.mainView.setLoadingState(isLoading)
            }
            .store(in: &cancellables)
    }

    // MARK: - Setups
    private func setupNavItem() {
        if #available(iOS 26.0, *) {
            navigationItem.titleView = NavTitleView(title: "측정")
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: NavTitleLabel(title: "측정"))
        }
    }

    private func setupDelegates() {
        mainView.searchBar.delegate = self
        mainView.searchResultsTableView.delegate = self
    }
    
    // MARK: - Private Methods
    
    // 네비게이션 타이틀 위치, 텍스트 변경
    private func setNavItem(isMeasuring: Bool) {
        if #available(iOS 26.0, *) {
            if isMeasuring {
                navigationItem.titleView = nil
                navigationItem.title = "측정 중"
            } else {
                navigationItem.titleView = NavTitleView(title: "측정")
            }
        } else {
            navigationItem.leftBarButtonItem?.isHidden = isMeasuring
            navigationItem.title = isMeasuring ? "측정 중" : nil
        }
    }
    
    // 후기 유도 뷰
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
    
    // 측정 취소 Alert
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

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let totalItems = dataSource.snapshot().numberOfItems
        // 마지막 셀보다 3개 전에 도달하면 다음 페이지 로드 시도
        if indexPath.row == totalItems - 3 {
            loadMoreTriggerSubject.send(())
        }
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
