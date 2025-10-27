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
    }

    struct Output {
        let mountainName: String
        let activityStat: ActivityStat
        let isLoadingChart: AnyPublisher<Bool, Never>
        let activityLogs: AnyPublisher<[ActivityLog], Never>
    }

    func transform(input: Input) -> Output {
        let stat = activityStatUseCase.execute(activityLogs: climbRecord.timeLog)

//        // 평균 통계 가져오기
//        getAverageActivityStatsUseCase.execute()
//            .sink { result in
//                switch result {
//                case .success(let averageStats):
//                    print("평균 통계:")
//                    print("  - 평균 총 소요시간: \(averageStats.averageTotalMinutes)분")
//                    print("  - 평균 운동 시간: \(averageStats.averageExerciseMinutes)분")
//                    print("  - 평균 휴식 시간: \(averageStats.averageRestMinutes)분")
//                    print("  - 평균 속도: \(String(format: "%.2f", averageStats.averageSpeed))m/분")
//                case .failure(let error):
//                    print("평균 통계 가져오기 실패: \(error)")
//                }
//            }
//            .store(in: &cancellables)

        // 차트 로딩 상태와 데이터 처리
        let chartSubject = PassthroughSubject<[ActivityLog], Never>()
        let isLoadingSubject = PassthroughSubject<Bool, Never>()

        input.viewDidAppear
            .prefix(1)
            .sink { [weak self] _ in
                guard let self = self else { return }
                chartSubject.send(climbRecord.timeLog)
                isLoadingSubject.send(false)
            }
            .store(in: &cancellables)

        return Output(
            mountainName: climbRecord.mountain.name,
            activityStat: stat,
            isLoadingChart: isLoadingSubject.eraseToAnyPublisher(),
            activityLogs: chartSubject.eraseToAnyPublisher()
        )
    }
}
