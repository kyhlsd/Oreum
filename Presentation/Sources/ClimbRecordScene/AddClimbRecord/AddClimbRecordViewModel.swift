//
//  AddClimbRecordViewModel.swift
//  Presentation
//
//  Created by 김영훈 on 10/2/25.
//

import Foundation
import Combine
import Domain

final class AddClimbRecordViewModel {

    struct Input {
        let searchTrigger: AnyPublisher<String, Never>
        let mountainSelected: AnyPublisher<Mountain, Never>
        let cancelMountain: AnyPublisher<Void, Never>
        let dateChanged: AnyPublisher<Date, Never>
        let nextButtonTapped: AnyPublisher<Void, Never>
    }

    struct Output {
        let searchResults: AnyPublisher<[Mountain], Never>
        let updateMountainLabelsTrigger: AnyPublisher<(String, String), Never>
        let clearMountainSelectionTrigger: AnyPublisher<Void, Never>
        let updateSearchResultsOverlayIsHiddenTrigger: AnyPublisher<Bool, Never>
        let updateSearchResultsTrigger: AnyPublisher<Int, Never>
        let clearSearchBarTrigger: AnyPublisher<Void, Never>
        let updateStartButtonIsEnabledTrigger: AnyPublisher<Bool, Never>
        let nextEnabled: AnyPublisher<Bool, Never>
        let pushDetailVC: AnyPublisher<ClimbRecord, Never>
        let errorMessage: AnyPublisher<String, Never>
    }

    private let fetchMountainsUseCase: FetchMountainsUseCase
    private let saveClimbRecordUseCase: SaveClimbRecordUseCase
    private var cancellables = Set<AnyCancellable>()

    init(
        fetchMountainsUseCase: FetchMountainsUseCase,
        saveClimbRecordUseCase: SaveClimbRecordUseCase
    ) {
        self.fetchMountainsUseCase = fetchMountainsUseCase
        self.saveClimbRecordUseCase = saveClimbRecordUseCase
    }

    func transform(input: Input) -> Output {
        let selectedMountainSubject = CurrentValueSubject<Mountain?, Never>(nil)
        let selectedDateSubject = CurrentValueSubject<Date, Never>(Date())
        let errorSubject = PassthroughSubject<String, Never>()
        let pushDetailVCSubject = PassthroughSubject<ClimbRecord, Never>()
        let updateSearchResultsOverlayIsHiddenSubject = PassthroughSubject<Bool, Never>()
        let updateSearchResultsCountSubject = PassthroughSubject<Int, Never>()

        // 검색 결과
        let searchResults = input.searchTrigger
            .debounce(for: .seconds(0.3), scheduler: RunLoop.main)
            .flatMap { [weak self] keyword -> AnyPublisher<[Mountain], Never> in
                guard let self else {
                    return Just([]).eraseToAnyPublisher()
                }
                return self.fetchMountainsUseCase.execute(keyword: keyword)
                    .map { mountainInfos in
                        mountainInfos.map { $0.toMountain() }
                    }
                    .catch { _ in Just([]) }
                    .eraseToAnyPublisher()
            }
            .share()
            .eraseToAnyPublisher()

        // 산 선택 시 라벨 업데이트
        let updateMountainLabels = input.mountainSelected
            .map { mountain -> (String, String) in
                selectedMountainSubject.send(mountain)
                return (mountain.name, mountain.address)
            }
            .eraseToAnyPublisher()

        // 산 선택 취소
        let clearMountainSelection = input.cancelMountain
            .handleEvents(receiveOutput: { _ in
                selectedMountainSubject.send(nil)
            })
            .eraseToAnyPublisher()

        // 산 선택 시 검색 결과 오버레이 숨김
        input.mountainSelected
            .sink { _ in
                updateSearchResultsOverlayIsHiddenSubject.send(true)
            }
            .store(in: &cancellables)

        let hideOverlay = updateSearchResultsOverlayIsHiddenSubject.eraseToAnyPublisher()

        // 검색 결과 개수 업데이트 및 오버레이 표시
        searchResults
            .sink { results in
                updateSearchResultsOverlayIsHiddenSubject.send(false)
                updateSearchResultsCountSubject.send(results.count)
            }
            .store(in: &cancellables)

        let updateSearchResultsCount = updateSearchResultsCountSubject.eraseToAnyPublisher()

        // 검색바 클리어
        let clearSearchBar = input.mountainSelected
            .map { _ in () }
            .eraseToAnyPublisher()

        // 시작 버튼 활성화
        let startButtonEnabled = selectedMountainSubject
            .map { $0 != nil }
            .eraseToAnyPublisher()

        // 날짜 변경
        input.dateChanged
            .sink { date in
                selectedDateSubject.send(date)
            }
            .store(in: &cancellables)

        // 다음 버튼 활성화
        let nextEnabled = selectedMountainSubject
            .map { $0 != nil }
            .prepend(false)
            .eraseToAnyPublisher()

        // 다음 버튼 탭
        input.nextButtonTapped
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .sink {
                guard let mountain = selectedMountainSubject.value else {
                    errorSubject.send("산을 선택해주세요.")
                    return
                }

                let date = selectedDateSubject.value

                let record = ClimbRecord(
                    id: UUID().uuidString,
                    mountain: mountain,
                    timeLog: [],
                    images: [],
                    score: 0,
                    comment: "",
                    isBookmarked: false,
                    climbDate: date
                )

                pushDetailVCSubject.send(record)
            }
            .store(in: &cancellables)

        return Output(
            searchResults: searchResults,
            updateMountainLabelsTrigger: updateMountainLabels,
            clearMountainSelectionTrigger: clearMountainSelection,
            updateSearchResultsOverlayIsHiddenTrigger: hideOverlay,
            updateSearchResultsTrigger: updateSearchResultsCount,
            clearSearchBarTrigger: clearSearchBar,
            updateStartButtonIsEnabledTrigger: startButtonEnabled,
            nextEnabled: nextEnabled,
            pushDetailVC: pushDetailVCSubject.eraseToAnyPublisher(),
            errorMessage: errorSubject.eraseToAnyPublisher()
        )
    }
}
