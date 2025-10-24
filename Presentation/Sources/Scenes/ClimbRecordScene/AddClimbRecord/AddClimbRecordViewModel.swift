//
//  AddClimbRecordViewModel.swift
//  Presentation
//
//  Created by 김영훈 on 10/2/25.
//

import Foundation
import Combine
import Domain

final class AddClimbRecordViewModel: BaseViewModel {

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
        let updateNextButtonIsEnabledTrigger: AnyPublisher<Bool, Never>
        let pushDetailVC: AnyPublisher<ClimbRecord, Never>
        let errorMessage: AnyPublisher<(String, String), Never>
        let isLoading: AnyPublisher<Bool, Never>
    }

    private let searchMountainUseCase: SearchMountainUseCase
    private let saveClimbRecordUseCase: SaveClimbRecordUseCase
    private var cancellables = Set<AnyCancellable>()

    init(
        searchMountainUseCase: SearchMountainUseCase,
        saveClimbRecordUseCase: SaveClimbRecordUseCase
    ) {
        self.searchMountainUseCase = searchMountainUseCase
        self.saveClimbRecordUseCase = saveClimbRecordUseCase
    }

    func transform(input: Input) -> Output {
        let selectedMountainSubject = CurrentValueSubject<Mountain?, Never>(nil)
        let selectedDateSubject = CurrentValueSubject<Date, Never>(Date())
        let errorSubject = PassthroughSubject<(String, String), Never>()
        let pushDetailVCSubject = PassthroughSubject<ClimbRecord, Never>()
        let updateSearchResultsOverlayIsHiddenSubject = PassthroughSubject<Bool, Never>()
        let updateSearchResultsCountSubject = PassthroughSubject<Int, Never>()
        let isLoadingSubject = PassthroughSubject<Bool, Never>()

        // 검색 결과
        let searchResultsSubject = PassthroughSubject<[Mountain], Never>()

        input.searchTrigger
            .debounce(for: .seconds(0.3), scheduler: RunLoop.main)
            .handleEvents(receiveOutput: { _ in
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
                    let mountains = response.body.items.item.map { $0.toMountain() }
                    searchResultsSubject.send(mountains)
                case .failure:
                    searchResultsSubject.send([])
                }
            }
            .store(in: &cancellables)

        let searchResults = searchResultsSubject
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

        // 검색 결과 개수 업데이트
        searchResults
            .sink { results in
                updateSearchResultsCountSubject.send(results.count)
            }
            .store(in: &cancellables)

        // 검색바 클리어
        let clearSearchBar = input.mountainSelected
            .map { _ in () }
            .eraseToAnyPublisher()

        // 다음 버튼 활성화
        let nextButtonEnabled = selectedMountainSubject
            .map { $0 != nil }
            .eraseToAnyPublisher()

        // 날짜 변경
        input.dateChanged
            .sink { date in
                selectedDateSubject.send(date)
            }
            .store(in: &cancellables)

        // 다음 버튼 탭
        input.nextButtonTapped
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .sink {
                guard let mountain = selectedMountainSubject.value else {
                    errorSubject.send(("산 선택 오류", "산을 선택해주세요."))
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
            updateSearchResultsTrigger: updateSearchResultsCountSubject.eraseToAnyPublisher(),
            clearSearchBarTrigger: clearSearchBar,
            updateNextButtonIsEnabledTrigger: nextButtonEnabled,
            pushDetailVC: pushDetailVCSubject.eraseToAnyPublisher(),
            errorMessage: errorSubject.eraseToAnyPublisher(),
            isLoading: isLoadingSubject.eraseToAnyPublisher()
        )
    }
}
