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
    private let requestTrackActivityAuthorizationUseCase: RequestTrackActivityAuthorizationUseCase
    private let startTrackingActivityUseCase: StartTrackingActivityUseCase
    private let getActivityLogsUseCase: GetActivityLogsUseCase
    private let stopTrackingActivityUseCase: StopTrackingActivityUseCase
    private let getTrackingStatusUseCase: GetTrackingStatusUseCase
    private let getCurrentActivityDataUseCase: GetCurrentActivityDataUseCase
    private let observeActivityDataUpdatesUseCase: ObserveActivityDataUpdatesUseCase
    private var cancellables = Set<AnyCancellable>()
    private var timeUpdateTimer: Timer?
    private var currentSteps: Int = 0
    private var currentDistance: Int = 0

    init(
        fetchMountainsUseCase: FetchMountainInfosUseCase,
        requestTrackActivityAuthorizationUseCase: RequestTrackActivityAuthorizationUseCase,
        startTrackingActivityUseCase: StartTrackingActivityUseCase,
        getActivityLogsUseCase: GetActivityLogsUseCase,
        stopTrackingActivityUseCase: StopTrackingActivityUseCase,
        getTrackingStatusUseCase: GetTrackingStatusUseCase,
        getCurrentActivityDataUseCase: GetCurrentActivityDataUseCase,
        observeActivityDataUpdatesUseCase: ObserveActivityDataUpdatesUseCase
    ) {
        self.fetchMountainsUseCase = fetchMountainsUseCase
        self.requestTrackActivityAuthorizationUseCase = requestTrackActivityAuthorizationUseCase
        self.startTrackingActivityUseCase = startTrackingActivityUseCase
        self.getActivityLogsUseCase = getActivityLogsUseCase
        self.stopTrackingActivityUseCase = stopTrackingActivityUseCase
        self.getTrackingStatusUseCase = getTrackingStatusUseCase
        self.getCurrentActivityDataUseCase = getCurrentActivityDataUseCase
        self.observeActivityDataUpdatesUseCase = observeActivityDataUpdatesUseCase
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
        let updateActivityDataTrigger: AnyPublisher<(time: String, distance: String, steps: String), Never>
    }

    func transform(input: Input) -> Output {
        let updateMountainLabelsSubject = PassthroughSubject<(String, String), Never>()
        let clearMountainSelectionSubject = PassthroughSubject<Void, Never>()
        let updateStartButtonIsEnabledSubject = CurrentValueSubject<Bool, Never>(false)
        let updateSearchResultsOverlayIsHiddenSubject = PassthroughSubject<Bool, Never>()
        let updateSearchResultsSubject = PassthroughSubject<Int, Never>()
        let updateMeasuringStateSubject = PassthroughSubject<Bool, Never>()
        let clearSearchBarSubject = PassthroughSubject<Void, Never>()
        let updateActivityDataSubject = PassthroughSubject<(time: String, distance: String, steps: String), Never>()

        let permissionCheckTrigger = Publishers.Merge(
            input.checkPermissionTrigger,
            input.didBecomeActive
        )

        let permissionAuthorized = permissionCheckTrigger
            .flatMap { [weak self] _ -> AnyPublisher<Bool, Never> in
                guard let self else {
                    return Just(false).eraseToAnyPublisher()
                }
                return self.requestTrackActivityAuthorizationUseCase.execute()
                    .catch { _ in Just(false) }
                    .eraseToAnyPublisher()
            }
            .removeDuplicates()
            .eraseToAnyPublisher()

        let trackingStatusSubject = CurrentValueSubject<Bool, Never>(false)

        input.checkTrackingStatusTrigger
            .flatMap { [weak self] _ -> AnyPublisher<Bool, Never> in
                guard let self else {
                    return Just(false).eraseToAnyPublisher()
                }
                return self.getTrackingStatusUseCase.execute()
            }
            .handleEvents(receiveOutput: { isTracking in
                print("🔍 ViewModel trackingStatus: \(isTracking)")
            })
            .sink { trackingStatusSubject.send($0) }
            .store(in: &cancellables)

        let trackingStatus = trackingStatusSubject.eraseToAnyPublisher()

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
                guard let self else { return }
                updateMeasuringStateSubject.send(true)
                self.startTrackingActivityUseCase.execute(startDate: Date())
                self.startActivityDataTimer(updateActivityDataSubject: updateActivityDataSubject)
            }
            .store(in: &cancellables)

        input.cancelMeasuring
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] in
                guard let self else { return }
                updateMeasuringStateSubject.send(false)
                self.stopActivityDataTimer()

                // 트래킹 중지 (데이터 저장 안 함)
                self.stopTrackingActivityUseCase.execute()
                print("✅ Activity tracking canceled")
            }
            .store(in: &cancellables)

        input.stopMeasuring
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .flatMap { [weak self] _ -> AnyPublisher<[ActivityLog], Never> in
                guard let self else { return Just([]).eraseToAnyPublisher() }
                self.stopActivityDataTimer()
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

        // tracking이 진행 중이면 타이머 시작
        trackingStatus
            .filter { $0 }
            .sink { [weak self] _ in
                self?.startActivityDataTimer(updateActivityDataSubject: updateActivityDataSubject)
            }
            .store(in: &cancellables)

        // trackingStatus와 버튼 액션을 병합
        let combinedMeasuringState = Publishers.Merge(trackingStatus, updateMeasuringStateSubject)
            .handleEvents(receiveOutput: { isMeasuring in
                print("🔍 combinedMeasuringState: \(isMeasuring)")
            })
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
            clearSearchBarTrigger: clearSearchBarSubject.eraseToAnyPublisher(),
            updateActivityDataTrigger: updateActivityDataSubject.eraseToAnyPublisher()
        )
    }

    // MARK: - Activity Data Timer
    private func startActivityDataTimer(updateActivityDataSubject: PassthroughSubject<(time: String, distance: String, steps: String), Never>) {
        print("🔍 startActivityDataTimer called")
        stopActivityDataTimer()

        // 즉시 한 번 Activity 데이터 가져오기
        fetchActivityData()
        // 즉시 한 번 UI 업데이트
        updateUI(updateActivityDataSubject: updateActivityDataSubject)

        // 1초마다 시간 업데이트
        timeUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateUI(updateActivityDataSubject: updateActivityDataSubject)
        }

        // Activity 데이터 변경 시 자동 업데이트
        observeActivityDataUpdatesUseCase.dataUpdates
            .sink { [weak self] _ in
                print("🔍 Activity data changed, fetching new data...")
                self?.fetchActivityData()
                self?.updateUI(updateActivityDataSubject: updateActivityDataSubject)
            }
            .store(in: &cancellables)
    }

    private func stopActivityDataTimer() {
        timeUpdateTimer?.invalidate()
        timeUpdateTimer = nil
        currentSteps = 0
        currentDistance = 0
    }

    private func fetchActivityData() {
        getCurrentActivityDataUseCase.execute()
            .catch { error in
                print("❌ Failed to get Activity data: \(error)")
                return Just((time: TimeInterval(0), steps: 0, distance: 0))
            }
            .sink { [weak self] data in
                self?.currentSteps = data.steps
                self?.currentDistance = data.distance
                print("🔍 Activity data updated - steps: \(data.steps), distance: \(data.distance)")
            }
            .store(in: &cancellables)
    }

    private func updateUI(updateActivityDataSubject: PassthroughSubject<(time: String, distance: String, steps: String), Never>) {
        getCurrentActivityDataUseCase.execute()
            .catch { _ in Just((time: TimeInterval(0), steps: 0, distance: 0)) }
            .sink { [weak self] data in
                guard let self else { return }
                let timeString = self.formatTime(data.time)
                let distanceString = String(format: "%.2f km", Double(self.currentDistance) / 1000.0)
                let stepsString = "\(self.currentSteps)"
                print("🔍 UI updated - time: \(timeString), steps: \(stepsString), distance: \(distanceString)")
                updateActivityDataSubject.send((time: timeString, distance: distanceString, steps: stepsString))
            }
            .store(in: &cancellables)
    }

    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let totalSeconds = Int(timeInterval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return "\(hours)시간 \(minutes)분 \(seconds)초"
        } else if minutes > 0 {
            return "\(minutes)분 \(seconds)초"
        } else {
            return "\(seconds)초"
        }
    }
}
