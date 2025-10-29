//
//  ActivityLogViewModel.swift
//  Presentation
//
//  Created by 김영훈 on 9/30/25.
//

import Foundation
import Domain
import Combine

final class ActivityLogViewModel: BaseViewModel {

    // ActivityLogs -> 통계 ActivityStat 변환
    private let activityStatUseCase: ActivityStatUseCase
    private let getAverageActivityStatsUseCase: GetAverageActivityStatsUseCase
    private var cancellables = Set<AnyCancellable>()

    private(set) var climbRecord: ClimbRecord

    init(
        activityStatUseCase: ActivityStatUseCase,
        getAverageActivityStatsUseCase: GetAverageActivityStatsUseCase,
        climbRecord: ClimbRecord
    ) {
        self.activityStatUseCase = activityStatUseCase
        self.getAverageActivityStatsUseCase = getAverageActivityStatsUseCase
        self.climbRecord = climbRecord
    }

    struct Input {
        let viewDidAppear: AnyPublisher<Void, Never>
        let activityChartDidRender: AnyPublisher<Void, Never>
        let timeChartDidRender: AnyPublisher<Void, Never>
    }

    struct Output {
        let mountainName: String
        let activityStat: ActivityStat
        let isLoadingActivityChart: AnyPublisher<Bool, Never>
        let activityLogs: AnyPublisher<[ActivityLog], Never>
        let isLoadingTimeChart: AnyPublisher<Bool, Never>
        let timeStats: AnyPublisher<(AverageActivityStat, ActivityStat), Never>
        let errorMessage: AnyPublisher<(String, String), Never>
    }

    func transform(input: Input) -> Output {
        let errorMessageSubject = PassthroughSubject<(String, String), Never>()
        
        let activityStat = activityStatUseCase.execute(activityLogs: climbRecord.timeLog)

        let viewDidAppear = input.viewDidAppear
            .prefix(1)
            .share()

        // 활동 차트 로딩 상태와 데이터 처리
        let activityChartSubject = PassthroughSubject<[ActivityLog], Never>()
        let activityIsLoadingSubject = PassthroughSubject<Bool, Never>()

        viewDidAppear
            .sink { [weak self] _ in
                guard let self else { return }
                activityIsLoadingSubject.send(true)
                activityChartSubject.send(climbRecord.timeLog)
            }
            .store(in: &cancellables)

        input.activityChartDidRender
            .sink { _ in
                activityIsLoadingSubject.send(false)
            }
            .store(in: &cancellables)
        
        // 시간 차트 로딩 상태와 데이터 처리
        let timeChartSubject = PassthroughSubject<(AverageActivityStat, ActivityStat), Never>()
        let timeIsLoadingSubject = PassthroughSubject<Bool, Never>()

        viewDidAppear
            .handleEvents(receiveOutput: { _ in
                timeIsLoadingSubject.send(true)
            })
            .flatMap { [weak self] _ -> AnyPublisher<Result<AverageActivityStat, Error>, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                return getAverageActivityStatsUseCase.execute()
            }
            .sink { result in
                switch result {
                case .success(let value):
                    timeChartSubject.send((value, activityStat))
                case .failure(let error):
                    errorMessageSubject.send(("평균 기록 불러오기 실패", error.localizedDescription))
                    timeIsLoadingSubject.send(false)
                }
            }
            .store(in: &cancellables)

        input.timeChartDidRender
            .sink { _ in
                timeIsLoadingSubject.send(false)
            }
            .store(in: &cancellables)

        return Output(
            mountainName: climbRecord.mountain.name,
            activityStat: activityStat,
            isLoadingActivityChart: activityIsLoadingSubject.eraseToAnyPublisher(),
            activityLogs: activityChartSubject.eraseToAnyPublisher(),
            isLoadingTimeChart: timeIsLoadingSubject.eraseToAnyPublisher(),
            timeStats: timeChartSubject.eraseToAnyPublisher(),
            errorMessage: errorMessageSubject.eraseToAnyPublisher()
        )
    }
}
