//
//  ActivityLogViewController.swift
//  Presentation
//
//  Created by 김영훈 on 9/30/25.
//

import UIKit
import Domain
import Combine

final class ActivityLogViewController: UIViewController, BaseViewController {

    let mainView = ActivityLogView()
    let viewModel: ActivityLogViewModel
    private let viewDidAppearSubject = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: ActivityLogViewModel) {
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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppearSubject.send()
    }

    func bind() {
        let input = ActivityLogViewModel.Input(
            viewDidAppear: viewDidAppearSubject.eraseToAnyPublisher()
        )
        let output = viewModel.transform(input: input)

        // 기본 정보는 바로 표시
        mainView.setMountainName(name: output.mountainName)
        mainView.setStat(activityStat: output.activityStat)

        // 차트 로딩 상태
        output.isLoadingChart
            .sink { [weak self] isLoading in
                self?.mainView.setChartLoading(isLoading)
            }
            .store(in: &cancellables)

        // 차트는 백그라운드에서 처리 후 표시
        output.activityLogs
            .sink { [weak self] activityLogs in
                self?.mainView.setActivityLogs(activityLogs: activityLogs)
            }
            .store(in: &cancellables)
    }

    private func setupNavItem() {
        navigationItem.title = "활동 타임라인"
        if #unavailable(iOS 26.0) {
            navigationItem.backButtonTitle = " "
        }
    }
}
