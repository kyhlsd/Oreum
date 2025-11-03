//
//  MeasureViewModel.swift
//  Presentation
//
//  Created by 김영훈 on 9/30/25.
//

import Foundation
import Combine
import Domain
import Core

final class MeasureViewModel: BaseViewModel {

    private let searchMountainUseCase: SearchMountainUseCase
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
    private var selectedMountain: Mountain?
    private var currentSteps: Int = 0
    private var currentDistance: Int = 0

    init(
        searchMountainUseCase: SearchMountainUseCase,
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
        self.searchMountainUseCase = searchMountainUseCase
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
        let loadMoreTrigger: AnyPublisher<Void, Never>
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
        let errorMessage: AnyPublisher<(String, String), Never>
        let isLoading: AnyPublisher<Bool, Never>
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
        let errorMessageSubject = PassthroughSubject<(String, String), Never>()
        let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)

        // 페이지네이션 상태
        let currentPageSubject = CurrentValueSubject<Int, Never>(1)
        let currentKeywordSubject = CurrentValueSubject<String, Never>("")
        let isLastPageSubject = CurrentValueSubject<Bool, Never>(false)
        let currentMountainsSubject = CurrentValueSubject<[MountainInfo], Never>([])

        let viewDidLoad = input.viewDidLoad
            .share()
        
        let trackingStatus = trackingStatusSubject
            .share()
            .eraseToAnyPublisher()
        
        let permissionAuthorizedSubject = CurrentValueSubject<Bool, Never>(false)
        
        let cleanUpSubject = PassthroughSubject<Void, Never>()
        
        // MARK: - 초기 실행
        
        // viewDidLoad, Active 상태가 됐을 때 권한 확인
        Publishers.Merge(
            viewDidLoad,
            input.didBecomeActive
        )
            .flatMap { [weak self] _ -> AnyPublisher<Result<Bool, Error>, Never> in
                guard let self else {
                    return Just(.success(false)).eraseToAnyPublisher()
                }
                return self.requestTrackActivityAuthorizationUseCase.execute()
            }
            .sink { result in
                switch result {
                case .success(let authorized):
                    permissionAuthorizedSubject.send(authorized)
                case .failure(let error):
                    errorMessageSubject.send(("권한 확인 실패", error.localizedDescription))
                    permissionAuthorizedSubject.send(false)
                }
            }
            .store(in: &cancellables)
        
        // permissionAuthorized와 trackingStatus 결합
        let authorizedMeasuringState = Publishers.CombineLatest(
            permissionAuthorizedSubject
                .removeDuplicates()
                .eraseToAnyPublisher(),
            trackingStatus
        )
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

        // 측정 중이면 저장된 산 정보 복원
        trackingStatus
            .filter { $0 }
            .sink { [weak self] _ in
                guard let self else { return }

                // 앱 재시작 시 Observer 재등록을 위해 기존 startDate로 startTracking 다시 호출
                if let startDate = self.startTrackingActivityUseCase.getStartDate(),
                   let mountain = self.getClimbingMountainUseCase.execute() {

                    // 측정 시작 시간이 24시간이 지났는지 확인
                    let elapsedTime = Date().timeIntervalSince(startDate)
                    let twentyFourHours: TimeInterval = 24 * 3600

                    if elapsedTime >= twentyFourHours {
                        // 24시간이 지났으면 측정 자동 취소
                        self.stopTrackingActivityUseCase.execute(clearData: true)
                        trackingStatusSubject.send(false)
                        errorMessageSubject.send(("측정 자동 취소", "24시간이 경과하여 측정이 자동으로 취소되었습니다."))
                    } else {
                        // 24시간 이내면 정상적으로 복원
                        self.startTrackingActivityUseCase.execute(startDate: startDate, mountain: mountain)

                        // 측정 중인 산 정보 복원
                        updateMountainLabelsSubject.send((mountain.name, mountain.address))
                    }
                }
            }
            .store(in: &cancellables)
        
        // MARK: - 산 선택

        // 산 검색 결과
        let searchResultsSubject = PassthroughSubject<[MountainInfo], Never>()

        // 새로운 검색
        input.searchTrigger
            .debounce(for: .seconds(0.3), scheduler: RunLoop.main)
            .handleEvents(receiveOutput: { keyword in
                currentKeywordSubject.send(keyword)
                currentPageSubject.send(1)
                isLastPageSubject.send(false)
                isLoadingSubject.send(true)
            })
            .flatMap { [weak self] keyword -> AnyPublisher<Result<MountainResponse, Error>, Never> in
                guard let self else {
                    return Empty().eraseToAnyPublisher()
                }
                return self.searchMountainUseCase.execute(keyword: keyword, page: 1)
            }
            .sink { result in
                isLoadingSubject.send(false)
                switch result {
                case .success(let response):
                    let mountains = response.body.items.item
                    currentMountainsSubject.send(mountains)
                    searchResultsSubject.send(mountains)

                    // 마지막 페이지 체크
                    if mountains.count >= response.body.totalCount {
                        isLastPageSubject.send(true)
                    }
                case .failure(let error):
                    errorMessageSubject.send(("검색 실패", error.localizedDescription))
                    currentMountainsSubject.send([])
                    searchResultsSubject.send([])
                    isLastPageSubject.send(true)
                }
            }
            .store(in: &cancellables)

        // 더 불러오기
        input.loadMoreTrigger
            .filter { !isLoadingSubject.value && !isLastPageSubject.value }
            .handleEvents(receiveOutput: { _ in
                isLoadingSubject.send(true)
            })
            .map { _ in (currentKeywordSubject.value, currentPageSubject.value + 1) }
            .flatMap { [weak self] (keyword, page) -> AnyPublisher<Result<MountainResponse, Error>, Never> in
                guard let self else {
                    return Empty().eraseToAnyPublisher()
                }
                return self.searchMountainUseCase.execute(keyword: keyword, page: page)
            }
            .sink { result in
                isLoadingSubject.send(false)
                switch result {
                case .success(let response):
                    let newMountains = response.body.items.item
                    let allMountains = currentMountainsSubject.value + newMountains
                    currentMountainsSubject.send(allMountains)
                    searchResultsSubject.send(allMountains)
                    currentPageSubject.send(currentPageSubject.value + 1)

                    // 마지막 페이지 체크
                    if allMountains.count >= response.body.totalCount {
                        isLastPageSubject.send(true)
                    }
                case .failure(let error):
                    errorMessageSubject.send(("검색 실패", error.localizedDescription))
                    isLastPageSubject.send(true)
                }
            }
            .store(in: &cancellables)

        let searchResults = searchResultsSubject
            .share()
            .eraseToAnyPublisher()

        // 검색 결과 높이 설정
        searchResults
            .sink { results in
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
            }
            .store(in: &cancellables)

        // 측정 취소
        input.cancelMeasuring
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] in
                guard let self else { return }

                // 트래킹 중지만 먼저 수행 (데이터는 아직 clear하지 않음)
                self.stopTrackingActivityUseCase.execute(clearData: false)

                // 산 정보가 남아있으면 selectedMountain에 복원하고 버튼 활성화
                if let mountain = self.getClimbingMountainUseCase.execute() {
                    self.selectedMountain = mountain
                    updateStartButtonIsEnabledSubject.send(true)
                }

                // 이제 clear
                self.stopTrackingActivityUseCase.execute(clearData: true)

                // Activity 데이터 초기화
                self.currentSteps = 0
                self.currentDistance = 0

                // 상태 업데이트
                trackingStatusSubject.send(false)
            }
            .store(in: &cancellables)

        // 측정 종료
        input.stopMeasuring
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .flatMap { [weak self] _ -> AnyPublisher<Result<[ActivityLog], Error>, Never> in
                guard let self else { return Just(.success([])).eraseToAnyPublisher() }
                return getActivityLogsUseCase.execute()
            }
            .sink { [weak self] result in
                guard let self else { return }

                // 산 정보 가져오기
                switch result {
                case .success(let logs):
                    guard let mountain = self.getClimbingMountainUseCase.execute() else {
                        // 산 정보가 없으면 초기화만 수행
                        cleanUpSubject.send(())
                        return
                    }

                    let startDate = logs.first?.time ?? Date()
                    let climbRecord = ClimbRecord(
                        id: UUID().uuidString,
                        mountain: mountain,
                        timeLog: logs,
                        images: [],
                        score: 0,
                        comment: "",
                        isBookmarked: false,
                        climbDate: startDate
                    )

                    // 기록 저장
                    self.saveClimbRecordUseCase.execute(record: climbRecord)
                        .sink { saveResult in
                            // 저장 완료 후 초기화
                            cleanUpSubject.send(())

                            switch saveResult {
                            case .success(let savedRecord):
                                NotificationCenter.default.post(name: .climbRecordDidSave, object: nil)
                                savedClimbRecordSubject.send(savedRecord)
                            case .failure:
                                NotificationCenter.default.post(name: .climbRecordDidSave, object: nil)
                                savedClimbRecordSubject.send(climbRecord)
                            }
                        }
                        .store(in: &self.cancellables)

                case .failure(let error):
                    errorMessageSubject.send(("산 정보 가져오기 실패", error.localizedDescription))
                    // 에러 발생 시에도 초기화
                    cleanUpSubject.send(())
                }
            }
            .store(in: &cancellables)
        
        // 측정 상태 초기화
        cleanUpSubject
            .sink { [weak self] in
                guard let self else { return }

                // 트래킹 중지 및 측정 중 정보 clear
                self.stopTrackingActivityUseCase.execute(clearData: true)

                // Activity 데이터 초기화
                self.currentSteps = 0
                self.currentDistance = 0

                // 산 선택, 측정 상태 초기화
                trackingStatusSubject.send(false)
                clearMountainSelectionSubject.send()
                updateStartButtonIsEnabledSubject.send(false)
                clearSearchBarSubject.send()
            }
            .store(in: &cancellables)

        // MARK: - Activity Data 업데이트

        // 측정 시작 시 초기 데이터 로드
        let initialDataTrigger = trackingStatus
            .filter { $0 }
            .map { _ in () }
            .eraseToAnyPublisher()

        // HealthKit 업데이트 시 + 초기 로드 시 걸음 수/거리 데이터 가져오기
        Publishers.Merge(
            initialDataTrigger,
            observeActivityDataUpdatesUseCase.dataUpdates
        )
        .flatMap { [weak self] _ -> AnyPublisher<Result<(time: TimeInterval, steps: Int, distance: Int), Error>, Never> in
            guard let self else {
                return Empty().eraseToAnyPublisher()
            }
            return self.getCurrentActivityDataUseCase.execute()
        }
        .sink { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                self.currentSteps = data.steps
                self.currentDistance = data.distance

                let timeString = self.formatTime(data.time)
                let distanceString = String(format: "%.2f km", Double(data.distance) / 1000.0)
                let stepsString = "\(data.steps)"
                updateActivityDataSubject.send((time: timeString, distance: distanceString, steps: stepsString))
            case .failure:
                self.currentSteps = 0
                self.currentDistance = 0

                let timeString = self.formatTime(0)
                let distanceString = "0.00 km"
                let stepsString = "0"
                updateActivityDataSubject.send((time: timeString, distance: distanceString, steps: stepsString))
            }
        }
        .store(in: &cancellables)

        // 1초마다 타이머 이벤트 발생 (측정 중일 때만) - 시간만 업데이트
        trackingStatus
            .map { isTracking -> AnyPublisher<Void, Never> in
                if isTracking {
                    return Timer.publish(every: 1.0, on: .main, in: .common)
                        .autoconnect()
                        .map { _ in () }
                        .eraseToAnyPublisher()
                } else {
                    return Empty().eraseToAnyPublisher()
                }
            }
            .switchToLatest()
            .sink { [weak self] _ in
                guard let self else { return }

                if let startDate = self.startTrackingActivityUseCase.getStartDate() {
                    let elapsedTime = Date().timeIntervalSince(startDate)
                    let timeString = self.formatTime(elapsedTime)
                    let distanceString = String(format: "%.2f km", Double(self.currentDistance) / 1000.0)
                    let stepsString = "\(self.currentSteps)"
                    updateActivityDataSubject.send((time: timeString, distance: distanceString, steps: stepsString))
                }
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
            savedClimbRecord: savedClimbRecordSubject.eraseToAnyPublisher(),
            errorMessage: errorMessageSubject.eraseToAnyPublisher(),
            isLoading: isLoadingSubject.eraseToAnyPublisher()
        )
    }

    // MARK: - Private Methods
    
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
