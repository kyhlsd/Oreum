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
        let saveButtonTapped: AnyPublisher<Void, Never>
    }

    struct Output {
        let searchResults: AnyPublisher<[Mountain], Never>
        let updateMountainLabelsTrigger: AnyPublisher<(String, String), Never>
        let clearMountainSelectionTrigger: AnyPublisher<Void, Never>
        let updateSearchResultsOverlayIsHiddenTrigger: AnyPublisher<Bool, Never>
        let updateSearchResultsTrigger: AnyPublisher<Int, Never>
        let clearSearchBarTrigger: AnyPublisher<Void, Never>
        let updateStartButtonIsEnabledTrigger: AnyPublisher<Bool, Never>
        let saveEnabled: AnyPublisher<Bool, Never>
        let dismiss: AnyPublisher<Void, Never>
        let errorMessage: AnyPublisher<String, Never>
    }

    private let fetchMountainInfosUseCase: FetchMountainInfosUseCase
    private let saveClimbRecordUseCase: SaveClimbRecordUseCase
    private var cancellables = Set<AnyCancellable>()

    init(
        fetchMountainInfosUseCase: FetchMountainInfosUseCase,
        saveClimbRecordUseCase: SaveClimbRecordUseCase
    ) {
        self.fetchMountainInfosUseCase = fetchMountainInfosUseCase
        self.saveClimbRecordUseCase = saveClimbRecordUseCase
    }

    func transform(input: Input) -> Output {
        let selectedMountainSubject = PassthroughSubject<Mountain?, Never>()
        let selectedDateSubject = CurrentValueSubject<Date?, Never>(Date())
        let errorSubject = PassthroughSubject<String, Never>()
        let dismissSubject = PassthroughSubject<Void, Never>()
        let updateSearchResultsOverlayIsHiddenSubject = PassthroughSubject<Bool, Never>()
        let updateSearchResultsCountSubject = PassthroughSubject<Int, Never>()

        // 검색 결과
        let searchResults = input.searchTrigger
            .debounce(for: .seconds(0.3), scheduler: RunLoop.main)
            .flatMap { [weak self] keyword -> AnyPublisher<[Mountain], Never> in
                guard let self else {
                    return Just([]).eraseToAnyPublisher()
                }
                return self.fetchMountainInfosUseCase.execute(keyword: keyword)
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

        // 저장 버튼 활성화
        let saveEnabled = selectedMountainSubject
            .map { $0 != nil }
            .prepend(false)
            .eraseToAnyPublisher()

        // 저장 버튼 탭
        Publishers.CombineLatest3(
            input.saveButtonTapped,
            selectedMountainSubject,
            selectedDateSubject
        )
        .sink { [weak self] _, mountain, date in
            guard let self,
                  let mountain = mountain,
                  let date = date else {
                errorSubject.send("산과 날짜를 선택해주세요.")
                return
            }

            let record = ClimbRecord(
                id: UUID().uuidString,
                mountain: mountain,
                timeLog: [
                    ActivityLog(id: UUID().uuidString, time: date, step: 0, distance: 0)
                ],
                images: [],
                score: 0,
                comment: "",
                isBookmarked: false
            )

            self.saveClimbRecordUseCase.execute(record: record)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            errorSubject.send(error.localizedDescription)
                        }
                    },
                    receiveValue: { _ in
                        NotificationCenter.default.post(name: .climbRecordDidSave, object: nil)
                        dismissSubject.send(())
                    }
                )
                .store(in: &self.cancellables)
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
            saveEnabled: saveEnabled,
            dismiss: dismissSubject.eraseToAnyPublisher(),
            errorMessage: errorSubject.eraseToAnyPublisher()
        )
    }
}
