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
    private let activityChartDidRenderSubject = PassthroughSubject<Void, Never>()
    private let timeChartDidRenderSubject = PassthroughSubject<Void, Never>()
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
            viewDidAppear: viewDidAppearSubject.eraseToAnyPublisher(),
            activityChartDidRender: activityChartDidRenderSubject.eraseToAnyPublisher(),
            timeChartDidRender: timeChartDidRenderSubject.eraseToAnyPublisher()
        )
        let output = viewModel.transform(input: input)

        // 차트 렌더링 완료 콜백 설정
        mainView.onActivityChartRendered = { [weak self] in
            self?.activityChartDidRenderSubject.send()
        }

        mainView.onTimeChartRendered = { [weak self] in
            self?.timeChartDidRenderSubject.send()
        }

        // 기본 정보는 바로 표시
        mainView.setMountainName(name: output.mountainName)
        mainView.setStat(activityStat: output.activityStat)

        // 시간 차트 로딩 상태
        output.isLoadingTimeChart
            .sink { [weak self] isLoading in
                self?.mainView.setTimeChartLoading(isLoading)
            }
            .store(in: &cancellables)

        // 시간 차트
        output.timeStats
            .sink { [weak self] (averageStat, activityStat) in
                self?.mainView.setTimeStats(averageStat: averageStat, activityStat: activityStat)
            }
            .store(in: &cancellables)
        
        // 활동 차트 로딩 상태
        output.isLoadingActivityChart
            .sink { [weak self] isLoading in
                self?.mainView.setActivityChartLoading(isLoading)
            }
            .store(in: &cancellables)

        // 활동 차트
        output.activityLogs
            .sink { [weak self] activityLogs in
                self?.mainView.setActivityLogs(activityLogs: activityLogs)
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
        navigationItem.title = "활동 타임라인"
        if #unavailable(iOS 26.0) {
            navigationItem.backButtonTitle = " "
        }
    }
}
