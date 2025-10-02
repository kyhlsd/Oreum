//
//  MeasureViewModel.swift
//  Presentation
//
//  Created by 김영훈 on 9/30/25.
//

import Foundation
import Combine
import Domain

final class MeasureViewModel: BaseViewModel {

    private let fetchMountainsUseCase: FetchMountainInfosUseCase
    private let requestHealthKitAuthorizationUseCase: RequestHealthKitAuthorizationUseCase
    private let startTrackingActivityUseCase: StartTrackingActivityUseCase
    private let getActivityLogsUseCase: GetActivityLogsUseCase
    private let stopTrackingActivityUseCase: StopTrackingActivityUseCase
    private let getTrackingStatusUseCase: GetTrackingStatusUseCase
    private var cancellables = Set<AnyCancellable>()

    init(
        fetchMountainsUseCase: FetchMountainInfosUseCase,
        requestHealthKitAuthorizationUseCase: RequestHealthKitAuthorizationUseCase,
        startTrackingActivityUseCase: StartTrackingActivityUseCase,
        getActivityLogsUseCase: GetActivityLogsUseCase,
        stopTrackingActivityUseCase: StopTrackingActivityUseCase,
        getTrackingStatusUseCase: GetTrackingStatusUseCase
    ) {
        self.fetchMountainsUseCase = fetchMountainsUseCase
        self.requestHealthKitAuthorizationUseCase = requestHealthKitAuthorizationUseCase
        self.startTrackingActivityUseCase = startTrackingActivityUseCase
        self.getActivityLogsUseCase = getActivityLogsUseCase
        self.stopTrackingActivityUseCase = stopTrackingActivityUseCase
        self.getTrackingStatusUseCase = getTrackingStatusUseCase
    }

    struct Input {
        let checkPermissionTrigger: AnyPublisher<Void, Never>
        let checkTrackingStatusTrigger: AnyPublisher<Void, Never>
        let searchTrigger: AnyPublisher<String, Never>
        let selectMountain: AnyPublisher<MountainInfo, Never>
        let cancelMountain: AnyPublisher<Void, Never>
        let startMeasuring: AnyPublisher<Void, Never>
        let cancelMeasuring: AnyPublisher<Void, Never>
        let stopMeasuring: AnyPublisher<Void, Never>
        let didBecomeActive: AnyPublisher<Void, Never>
    }

    struct Output {
        let permissionAuthorized: AnyPublisher<Bool, Never>
        let trackingStatus: AnyPublisher<Bool, Never>
        let searchResults: AnyPublisher<[MountainInfo], Never>
        let updateMountainLabelsTrigger: AnyPublisher<(String, String), Never>
        let clearMountainSelectionTrigger: AnyPublisher<Void, Never>
        let updateStartButtonIsEnabledTrigger: AnyPublisher<Bool, Never>
        let updateSearchResultsOverlayIsHiddenTrigger: AnyPublisher<Bool, Never>
        let updateSearchResultsTrigger: AnyPublisher<Int, Never>
        let updateMeasuringStateTrigger: AnyPublisher<Bool, Never>
        let clearSearchBarTrigger: AnyPublisher<Void, Never>
    }

    func transform(input: Input) -> Output {
        let updateMountainLabelsSubject = PassthroughSubject<(String, String), Never>()
        let clearMountainSelectionSubject = PassthroughSubject<Void, Never>()
        let updateStartButtonIsEnabledSubject = CurrentValueSubject<Bool, Never>(false)
        let updateSearchResultsOverlayIsHiddenSubject = PassthroughSubject<Bool, Never>()
        let updateSearchResultsSubject = PassthroughSubject<Int, Never>()
        let updateMeasuringStateSubject = PassthroughSubject<Bool, Never>()
        let clearSearchBarSubject = PassthroughSubject<Void, Never>()

        let permissionCheckTrigger = Publishers.Merge(
            input.checkPermissionTrigger,
            input.didBecomeActive
        )

        let permissionAuthorized = permissionCheckTrigger
            .flatMap { [weak self] _ -> AnyPublisher<Bool, Never> in
                guard let self else {
                    return Just(false).eraseToAnyPublisher()
                }
                return self.requestHealthKitAuthorizationUseCase.execute()
                    .catch { _ in Just(false) }
                    .eraseToAnyPublisher()
            }
            .removeDuplicates()
            .eraseToAnyPublisher()

        let trackingStatus = input.checkTrackingStatusTrigger
            .flatMap { [weak self] _ -> AnyPublisher<Bool, Never> in
                guard let self else {
                    return Just(false).eraseToAnyPublisher()
                }
                return self.getTrackingStatusUseCase.execute()
            }
            .share()
            .eraseToAnyPublisher()

        let searchResults = input.searchTrigger
            .debounce(for: .seconds(0.3), scheduler: RunLoop.main)
            .flatMap { [weak self] keyword -> AnyPublisher<[MountainInfo], Never> in
                guard let self else {
                    return Just([]).eraseToAnyPublisher()
                }
                return self.fetchMountainsUseCase.execute(keyword: keyword)
                    .catch { _ in Just([]) }
                    .eraseToAnyPublisher()
            }
            .share()
            .eraseToAnyPublisher()

        searchResults
            .sink { results in
                updateSearchResultsOverlayIsHiddenSubject.send(false)
                updateSearchResultsSubject.send(results.count)
            }
            .store(in: &cancellables)

        input.selectMountain
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .sink { mountainInfo in
                updateMountainLabelsSubject.send((mountainInfo.name, mountainInfo.address))
                updateStartButtonIsEnabledSubject.send(true)
                updateSearchResultsOverlayIsHiddenSubject.send(true)
            }
            .store(in: &cancellables)

        input.cancelMountain
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .sink {
                clearMountainSelectionSubject.send()
                updateStartButtonIsEnabledSubject.send(false)
            }
            .store(in: &cancellables)

        input.startMeasuring
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] in
                updateMeasuringStateSubject.send(true)
                self?.startTrackingActivityUseCase.execute(startDate: Date())
            }
            .store(in: &cancellables)

        input.cancelMeasuring
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] in
                updateMeasuringStateSubject.send(false)

                // 트래킹 중지 (데이터 저장 안 함)
                self?.stopTrackingActivityUseCase.execute()
                print("✅ Activity tracking canceled")
            }
            .store(in: &cancellables)

        input.stopMeasuring
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .flatMap { [weak self] _ -> AnyPublisher<[ActivityLog], Never> in
                guard let self else { return Just([]).eraseToAnyPublisher() }
                return getActivityLogsUseCase.execute()
                    .catch { error -> Just<[ActivityLog]> in
                        print("❌ Failed to get activity logs: \(error)")
                        return Just([])
                    }.eraseToAnyPublisher()
            }
            .sink { [weak self] logs in
                updateMeasuringStateSubject.send(false)
                clearMountainSelectionSubject.send()
                updateStartButtonIsEnabledSubject.send(false)
                clearSearchBarSubject.send()

                print("✅ Activity logs (\(logs.count) entries):")
                for log in logs {
                    print("  - Time: \(log.time), Steps: \(log.step), Distance: \(log.distance)m")
                }

                // 트래킹 중지
                self?.stopTrackingActivityUseCase.execute()
            }
            .store(in: &cancellables)

        // trackingStatus와 버튼 액션을 병합
        let combinedMeasuringState = Publishers.Merge(trackingStatus, updateMeasuringStateSubject)
            .removeDuplicates()
            .eraseToAnyPublisher()

        return Output(
            permissionAuthorized: permissionAuthorized,
            trackingStatus: trackingStatus,
            searchResults: searchResults,
            updateMountainLabelsTrigger: updateMountainLabelsSubject.eraseToAnyPublisher(),
            clearMountainSelectionTrigger: clearMountainSelectionSubject.eraseToAnyPublisher(),
            updateStartButtonIsEnabledTrigger: updateStartButtonIsEnabledSubject
                .removeDuplicates()
                .eraseToAnyPublisher(),
            updateSearchResultsOverlayIsHiddenTrigger: updateSearchResultsOverlayIsHiddenSubject
                .eraseToAnyPublisher(),
            updateSearchResultsTrigger: updateSearchResultsSubject.eraseToAnyPublisher(),
            updateMeasuringStateTrigger: combinedMeasuringState,
            clearSearchBarTrigger: clearSearchBarSubject.eraseToAnyPublisher()
        )
    }
}
