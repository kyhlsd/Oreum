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
        let viewDidLoad: AnyPublisher<Void, Never>
        let searchTrigger: AnyPublisher<String, Never>
        let selectMountain: AnyPublisher<MountainInfo, Never>
        let cancelMountain: AnyPublisher<Void, Never>
        let startMeasuring: AnyPublisher<Void, Never>
        let cancelMeasuring: AnyPublisher<Void, Never>
        let stopMeasuring: AnyPublisher<Void, Never>
        let didBecomeActive: AnyPublisher<Void, Never>
    }

    struct Output {
        let authorizedMeasuringState: AnyPublisher<(authorized: Bool, isMeasuring: Bool), Never>
        let searchResults: AnyPublisher<[MountainInfo], Never>
        let updateMountainLabelsTrigger: AnyPublisher<(String, String), Never>
        let clearMountainSelectionTrigger: AnyPublisher<Void, Never>
        let updateStartButtonIsEnabledTrigger: AnyPublisher<Bool, Never>
        let updateSearchResultsOverlayIsHiddenTrigger: AnyPublisher<Bool, Never>
        let updateSearchResultsTrigger: AnyPublisher<Int, Never>
        let clearSearchBarTrigger: AnyPublisher<Void, Never>
        let updateActivityDataTrigger: AnyPublisher<(time: String, distance: String, steps: String), Never>
        let savedClimbRecord: AnyPublisher<ClimbRecord, Never>
    }

    func transform(input: Input) -> Output {
        let updateMountainLabelsSubject = PassthroughSubject<(String, String), Never>()
        let clearMountainSelectionSubject = PassthroughSubject<Void, Never>()
        let updateStartButtonIsEnabledSubject = CurrentValueSubject<Bool, Never>(false)
        let updateSearchResultsOverlayIsHiddenSubject = PassthroughSubject<Bool, Never>()
        let updateSearchResultsSubject = PassthroughSubject<Int, Never>()
        let clearSearchBarSubject = PassthroughSubject<Void, Never>()
        let updateActivityDataSubject = PassthroughSubject<(time: String, distance: String, steps: String), Never>()
        let savedClimbRecordSubject = PassthroughSubject<ClimbRecord, Never>()
        let trackingStatusSubject = CurrentValueSubject<Bool, Never>(false)

        let viewDidLoad = input.viewDidLoad
            .share()
        
        let trackingStatus = trackingStatusSubject
            .share()
            .eraseToAnyPublisher()

        // MARK: - 초기 실행
        
        // viewDidLoad, Active 상태가 됐을 때 권한 확인
        let permissionAuthorized = Publishers.Merge(
            viewDidLoad,
            input.didBecomeActive
        )
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
        
        // permissionAuthorized와 trackingStatus 결합
        let authorizedMeasuringState = Publishers.CombineLatest(permissionAuthorized, trackingStatus)
            .map { (authorized: $0, isMeasuring: $1) }
            .eraseToAnyPublisher()

        // 측정 중인지 확인
        viewDidLoad
            .flatMap { [weak self] _ -> AnyPublisher<Bool, Never> in
                guard let self else {
                    return Just(false).eraseToAnyPublisher()
                }
                return self.getTrackingStatusUseCase.execute()
            }
            .sink { trackingStatusSubject.send($0) }
            .store(in: &cancellables)

        // 측정 중이면 저장된 산 정보 복원 및 타이머 시작
        trackingStatus
            .filter { $0 }
            .sink { [weak self] _ in
                guard let self else { return }

                // 앱 재시작 시 Observer 재등록을 위해 기존 startDate로 startTracking 다시 호출
                if let startDate = self.startTrackingActivityUseCase.getStartDate(),
                   let mountain = self.getClimbingMountainUseCase.execute() {
                    self.startTrackingActivityUseCase.execute(startDate: startDate, mountain: mountain)

                    // 측정 중인 산 정보 복원
                    updateMountainLabelsSubject.send((mountain.name, mountain.address))
                }

                self.startActivityDataTimer(updateActivityDataSubject: updateActivityDataSubject)
            }
            .store(in: &cancellables)
        
        // MARK: - 산 선택
        
        // 산 검색 결과
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

        // 검색 결과 오버레이, 높이 설정
        searchResults
            .sink { results in
                updateSearchResultsOverlayIsHiddenSubject.send(false)
                updateSearchResultsSubject.send(results.count)
            }
            .store(in: &cancellables)

        // 산 선택
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

        // 산 선택 취소
        input.cancelMountain
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] in
                self?.selectedMountain = nil
                clearMountainSelectionSubject.send()
                updateStartButtonIsEnabledSubject.send(false)
            }
            .store(in: &cancellables)

        // MARK: - 측정
        
        // 측정 시작
        input.startMeasuring
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] in
                guard let self else { return }
                guard let mountain = self.selectedMountain else { return }

                trackingStatusSubject.send(true)
                self.startTrackingActivityUseCase.execute(startDate: Date(), mountain: mountain)
                self.startActivityDataTimer(updateActivityDataSubject: updateActivityDataSubject)
            }
            .store(in: &cancellables)

        // 측정 취소
        input.cancelMeasuring
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] in
                guard let self else { return }

                // 트래킹 중지만 먼저 수행 (데이터는 아직 clear하지 않음)
                self.stopTrackingActivityUseCase.execute(clearData: false)
                self.stopActivityDataTimer()

                // 산 정보가 남아있으면 selectedMountain에 복원하고 버튼 활성화
                if let mountain = self.getClimbingMountainUseCase.execute() {
                    self.selectedMountain = mountain
                    updateStartButtonIsEnabledSubject.send(true)
                }

                // 이제 clear
                self.stopTrackingActivityUseCase.execute(clearData: true)

                // 상태 업데이트
                trackingStatusSubject.send(false)
            }
            .store(in: &cancellables)

        // 측정 종료
        input.stopMeasuring
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .flatMap { [weak self] _ -> AnyPublisher<(logs: [ActivityLog], mountain: Mountain?), Never> in
                guard let self else { return Just((logs: [], mountain: nil)).eraseToAnyPublisher() }
                let mountain = self.getClimbingMountainUseCase.execute()
                return getActivityLogsUseCase.execute()
                    .map { (logs: $0, mountain: mountain) }
                    .catch { error -> Just<(logs: [ActivityLog], mountain: Mountain?)> in
                        return Just((logs: [], mountain: mountain))
                    }.eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { [weak self] _ in
                // 산 선택, 측정 상태 초기화
                trackingStatusSubject.send(false)
                clearMountainSelectionSubject.send()
                updateStartButtonIsEnabledSubject.send(false)
                clearSearchBarSubject.send()

                // 타이머 종료
                self?.stopActivityDataTimer()
                // 트래킹 중지 및 측정 중 정보 clear
                self?.stopTrackingActivityUseCase.execute(clearData: true)
            })
            .compactMap { data -> ClimbRecord? in
                guard let mountain = data.mountain else { return nil }
                let startDate = data.logs.first?.time ?? Date()
                return ClimbRecord(
                    id: UUID().uuidString,
                    mountain: mountain,
                    timeLog: data.logs,
                    images: [],
                    score: 0,
                    comment: "",
                    isBookmarked: false,
                    climbDate: startDate
                )
            }
            .flatMap { [weak self] climbRecord -> AnyPublisher<ClimbRecord, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                // 기록 저장
                return self.saveClimbRecordUseCase.execute(record: climbRecord)
                    .catch { _ in Just(climbRecord) }
                    .eraseToAnyPublisher()
            }
            .sink { savedRecord in
                // 저장 완료 후 Notification 전송
                NotificationCenter.default.post(name: .climbRecordDidSave, object: nil)
                // 저장된 기록 전달
                savedClimbRecordSubject.send(savedRecord)
            }
            .store(in: &cancellables)


        // 걸음 수, 이동 거리 데이터 변경 시 자동 업데이트
        observeActivityDataUpdatesUseCase.dataUpdates
            .sink { [weak self] _ in
                self?.fetchActivityData()
                self?.updateUI(updateActivityDataSubject: updateActivityDataSubject)
            }
            .store(in: &cancellables)

        return Output(
            authorizedMeasuringState: authorizedMeasuringState,
            searchResults: searchResults,
            updateMountainLabelsTrigger: updateMountainLabelsSubject.eraseToAnyPublisher(),
            clearMountainSelectionTrigger: clearMountainSelectionSubject.eraseToAnyPublisher(),
            updateStartButtonIsEnabledTrigger: updateStartButtonIsEnabledSubject
                .removeDuplicates()
                .eraseToAnyPublisher(),
            updateSearchResultsOverlayIsHiddenTrigger: updateSearchResultsOverlayIsHiddenSubject
                .eraseToAnyPublisher(),
            updateSearchResultsTrigger: updateSearchResultsSubject.eraseToAnyPublisher(),
            clearSearchBarTrigger: clearSearchBarSubject.eraseToAnyPublisher(),
            updateActivityDataTrigger: updateActivityDataSubject.eraseToAnyPublisher(),
            savedClimbRecord: savedClimbRecordSubject.eraseToAnyPublisher()
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

    // Timer 종료
    private func stopActivityDataTimer() {
        timeUpdateTimer?.invalidate()
        timeUpdateTimer = nil
        currentSteps = 0
        currentDistance = 0
    }

    // 걸음 수, 이동 거리 불러오기
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

    // UI update
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

    // 시간 표기 형식
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
