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

    private let fetchMountainsUseCase: FetchMountainsUseCase
    private let requestTrackActivityAuthorizationUseCase: RequestTrackActivityAuthorizationUseCase
    private let startTrackingActivityUseCase: StartTrackingActivityUseCase
    private let getActivityLogsUseCase: GetActivityLogsUseCase
    private let stopTrackingActivityUseCase: StopTrackingActivityUseCase
    private let getTrackingStatusUseCase: GetTrackingStatusUseCase
    private let getCurrentActivityDataUseCase: GetCurrentActivityDataUseCase
    private let observeActivityDataUpdatesUseCase: ObserveActivityDataUpdatesUseCase
    private let getClimbingMountainUseCase: GetClimbingMountainUseCase
    private let saveClimbRecordUseCase: SaveClimbRecordUseCase
    private var cancellables = Set<AnyCancellable>()
    private var timeUpdateTimer: Timer?
    private var currentSteps: Int = 0
    private var currentDistance: Int = 0
    private var selectedMountain: Mountain?

    init(
        fetchMountainsUseCase: FetchMountainsUseCase,
        requestTrackActivityAuthorizationUseCase: RequestTrackActivityAuthorizationUseCase,
        startTrackingActivityUseCase: StartTrackingActivityUseCase,
        getActivityLogsUseCase: GetActivityLogsUseCase,
        stopTrackingActivityUseCase: StopTrackingActivityUseCase,
        getTrackingStatusUseCase: GetTrackingStatusUseCase,
        getCurrentActivityDataUseCase: GetCurrentActivityDataUseCase,
        observeActivityDataUpdatesUseCase: ObserveActivityDataUpdatesUseCase,
        getClimbingMountainUseCase: GetClimbingMountainUseCase,
        saveClimbRecordUseCase: SaveClimbRecordUseCase
    ) {
        self.fetchMountainsUseCase = fetchMountainsUseCase
        self.requestTrackActivityAuthorizationUseCase = requestTrackActivityAuthorizationUseCase
        self.startTrackingActivityUseCase = startTrackingActivityUseCase
        self.getActivityLogsUseCase = getActivityLogsUseCase
        self.stopTrackingActivityUseCase = stopTrackingActivityUseCase
        self.getTrackingStatusUseCase = getTrackingStatusUseCase
        self.getCurrentActivityDataUseCase = getCurrentActivityDataUseCase
        self.observeActivityDataUpdatesUseCase = observeActivityDataUpdatesUseCase
        self.getClimbingMountainUseCase = getClimbingMountainUseCase
        self.saveClimbRecordUseCase = saveClimbRecordUseCase
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
        let restoreMountainInfoTrigger: AnyPublisher<(String, String)?, Never>
        let savedClimbRecord: AnyPublisher<ClimbRecord, Never>
        let authorizedMeasuringState: AnyPublisher<(authorized: Bool, isMeasuring: Bool), Never>
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
        let savedClimbRecordSubject = PassthroughSubject<ClimbRecord, Never>()

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
            .sink { trackingStatusSubject.send($0) }
            .store(in: &cancellables)

        let trackingStatus = trackingStatusSubject.eraseToAnyPublisher()

        // tracking 중이면 저장된 산 정보를 함께 전달
        let restoreMountainInfo = trackingStatus
            .map { [weak self] isTracking -> (String, String)? in
                guard isTracking else { return nil }
                let mountain = self?.getClimbingMountainUseCase.execute()
                if let mountain = mountain {
                    return (mountain.name, mountain.address)
                }
                return nil
            }
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
            .sink { [weak self] mountainInfo in
                let mountain = mountainInfo.toMountain()
                self?.selectedMountain = mountain
                updateMountainLabelsSubject.send((mountainInfo.name, mountainInfo.address))
                updateStartButtonIsEnabledSubject.send(true)
                updateSearchResultsOverlayIsHiddenSubject.send(true)
            }
            .store(in: &cancellables)

        input.cancelMountain
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] in
                self?.selectedMountain = nil
                clearMountainSelectionSubject.send()
                updateStartButtonIsEnabledSubject.send(false)
            }
            .store(in: &cancellables)

        input.startMeasuring
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] in
                guard let self else { return }
                guard let mountain = self.selectedMountain else { return }

                updateMeasuringStateSubject.send(true)
                self.startTrackingActivityUseCase.execute(startDate: Date(), mountain: mountain)
                self.startActivityDataTimer(updateActivityDataSubject: updateActivityDataSubject)
            }
            .store(in: &cancellables)

        input.cancelMeasuring
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] in
                guard let self else { return }
                updateMeasuringStateSubject.send(false)
                self.stopActivityDataTimer()

                // 산 정보가 남아있으면 버튼 활성화
                if self.selectedMountain != nil {
                    updateStartButtonIsEnabledSubject.send(true)
                }

                // 트래킹 중지 (데이터 저장 안 함, UserDefaults clear)
                self.stopTrackingActivityUseCase.execute(clearData: true)
            }
            .store(in: &cancellables)

        let activityLogs = input.stopMeasuring
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.stopActivityDataTimer()
            })
            .flatMap { [weak self] _ -> AnyPublisher<[ActivityLog], Never> in
                guard let self else { return Just([]).eraseToAnyPublisher() }
                return getActivityLogsUseCase.execute()
                    .catch { error -> Just<[ActivityLog]> in
                        return Just([])
                    }.eraseToAnyPublisher()
            }
            .share()

        activityLogs
            .compactMap { [weak self] logs -> ClimbRecord? in
                guard let self else { return nil }
                guard let mountain = self.getClimbingMountainUseCase.execute() else { return nil }
                let startDate = logs.first?.time ?? Date()
                return ClimbRecord(
                    id: UUID().uuidString,
                    mountain: mountain,
                    timeLog: logs,
                    images: [],
                    score: 0,
                    comment: "",
                    isBookmarked: false,
                    climbDate: startDate
                )
            }
            .flatMap { [weak self] climbRecord -> AnyPublisher<ClimbRecord, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                return self.saveClimbRecordUseCase.execute(record: climbRecord)
                    .map { climbRecord }
                    .catch { error -> Just<ClimbRecord> in
                        return Just(climbRecord)
                    }
                    .eraseToAnyPublisher()
            }
            .sink { climbRecord in
                // 저장 성공 시 Notification 전송 (기록 리스트 갱신용)
                NotificationCenter.default.post(name: .climbRecordDidSave, object: nil)
                // 저장된 ClimbRecord 전달
                savedClimbRecordSubject.send(climbRecord)
            }
            .store(in: &cancellables)

        activityLogs
            .sink { [weak self] _ in
                guard let self else { return }
                updateMeasuringStateSubject.send(false)
                clearMountainSelectionSubject.send()
                updateStartButtonIsEnabledSubject.send(false)
                clearSearchBarSubject.send()

                // 트래킹 중지 및 UserDefaults clear
                self.stopTrackingActivityUseCase.execute(clearData: true)
            }
            .store(in: &cancellables)

        // Activity 데이터 변경 시 자동 업데이트 (한 번만 구독)
        observeActivityDataUpdatesUseCase.dataUpdates
            .sink { [weak self] _ in
                self?.fetchActivityData()
                self?.updateUI(updateActivityDataSubject: updateActivityDataSubject)
            }
            .store(in: &cancellables)

        // tracking이 진행 중이면 타이머 시작 및 Observer 재등록
        trackingStatus
            .filter { $0 }
            .sink { [weak self] _ in
                guard let self else { return }

                // 앱 재시작 시 Observer 재등록을 위해 기존 startDate로 startTracking 다시 호출
                if let startDate = self.startTrackingActivityUseCase.getStartDate(),
                   let mountain = self.getClimbingMountainUseCase.execute() {
                    self.startTrackingActivityUseCase.execute(startDate: startDate, mountain: mountain)
                }

                self.startActivityDataTimer(updateActivityDataSubject: updateActivityDataSubject)
            }
            .store(in: &cancellables)

        // trackingStatus와 버튼 액션을 병합
        let combinedMeasuringState = Publishers.Merge(trackingStatus, updateMeasuringStateSubject)
            .removeDuplicates()
            .eraseToAnyPublisher()

        // permissionAuthorized와 combinedMeasuringState 결합
        let authorizedMeasuringState = Publishers.CombineLatest(permissionAuthorized, combinedMeasuringState)
            .map { (authorized: $0, isMeasuring: $1) }
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
            updateActivityDataTrigger: updateActivityDataSubject.eraseToAnyPublisher(),
            restoreMountainInfoTrigger: restoreMountainInfo,
            savedClimbRecord: savedClimbRecordSubject.eraseToAnyPublisher(),
            authorizedMeasuringState: authorizedMeasuringState
        )
    }

    // MARK: - Activity Data Timer
    private func startActivityDataTimer(updateActivityDataSubject: PassthroughSubject<(time: String, distance: String, steps: String), Never>) {
        stopActivityDataTimer()

        // 즉시 한 번 Activity 데이터 가져오기
        fetchActivityData()
        // 즉시 한 번 UI 업데이트
        updateUI(updateActivityDataSubject: updateActivityDataSubject)

        // 1초마다 시간 업데이트
        timeUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateUI(updateActivityDataSubject: updateActivityDataSubject)
        }
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
                return Just((time: TimeInterval(0), steps: 0, distance: 0))
            }
            .sink { [weak self] data in
                self?.currentSteps = data.steps
                self?.currentDistance = data.distance
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
