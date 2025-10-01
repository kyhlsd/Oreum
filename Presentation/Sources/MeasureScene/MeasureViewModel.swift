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
    private var cancellables = Set<AnyCancellable>()

    init(fetchMountainsUseCase: FetchMountainInfosUseCase) {
        self.fetchMountainsUseCase = fetchMountainsUseCase
    }

    struct Input {
        let searchTrigger: AnyPublisher<String, Never>
        let selectMountain: AnyPublisher<MountainInfo, Never>
        let cancelMountain: AnyPublisher<Void, Never>
        let startMeasuring: AnyPublisher<Void, Never>
        let cancelMeasuring: AnyPublisher<Void, Never>
        let stopMeasuring: AnyPublisher<Void, Never>
    }

    struct Output {
        let searchResults: AnyPublisher<[MountainInfo], Never>
        let updateMountainLabelsTrigger: AnyPublisher<(String, String), Never>
        let updateMountainBoxIsHiddenTrigger: AnyPublisher<Bool, Never>
        let updateStartButtonIsEnabledTrigger: AnyPublisher<Bool, Never>
        let updateSearchResultsOverlayIsHiddenTrigger: AnyPublisher<Bool, Never>
        let updateSearchResultsTrigger: AnyPublisher<Int, Never>
        let updateMeasuringStateTrigger: AnyPublisher<Bool, Never>
        let clearSearchBarTrigger: AnyPublisher<Void, Never>
    }

    func transform(input: Input) -> Output {
        let updateMountainLabelsSubject = PassthroughSubject<(String, String), Never>()
        let updateMountainBoxIsHiddenSubject = CurrentValueSubject<Bool, Never>(true)
        let updateStartButtonIsEnabledSubject = CurrentValueSubject<Bool, Never>(false)
        let updateSearchResultsOverlayIsHiddenSubject = PassthroughSubject<Bool, Never>()
        let updateSearchResultsSubject = PassthroughSubject<Int, Never>()
        let updateMeasuringStateSubject = CurrentValueSubject<Bool, Never>(false)
        let clearSearchBarSubject = PassthroughSubject<Void, Never>()

        let searchResults = input.searchTrigger
            .debounce(for: .seconds(0.3), scheduler: RunLoop.main)
            .flatMap { [weak self] keyword -> AnyPublisher<[MountainInfo], Never> in
                guard let self = self else {
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
                updateMountainBoxIsHiddenSubject.send(false)
                updateStartButtonIsEnabledSubject.send(true)
                updateSearchResultsOverlayIsHiddenSubject.send(true)
            }
            .store(in: &cancellables)

        input.cancelMountain
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .sink {
                updateMountainBoxIsHiddenSubject.send(true)
                updateStartButtonIsEnabledSubject.send(false)
            }
            .store(in: &cancellables)

        input.startMeasuring
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .sink {
                updateMeasuringStateSubject.send(true)
            }
            .store(in: &cancellables)

        input.cancelMeasuring
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .sink {
                updateMeasuringStateSubject.send(false)
            }
            .store(in: &cancellables)

        input.stopMeasuring
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .sink {
                updateMeasuringStateSubject.send(false)
                updateMountainBoxIsHiddenSubject.send(true)
                updateStartButtonIsEnabledSubject.send(false)
                clearSearchBarSubject.send()
            }
            .store(in: &cancellables)

        return Output(searchResults: searchResults,
                      updateMountainLabelsTrigger: updateMountainLabelsSubject.eraseToAnyPublisher(),
                      updateMountainBoxIsHiddenTrigger: updateMountainBoxIsHiddenSubject
            .removeDuplicates()
            .eraseToAnyPublisher(),
                      updateStartButtonIsEnabledTrigger: updateStartButtonIsEnabledSubject
            .removeDuplicates()
            .eraseToAnyPublisher(),
                      updateSearchResultsOverlayIsHiddenTrigger: updateSearchResultsOverlayIsHiddenSubject
            .eraseToAnyPublisher(),
                      updateSearchResultsTrigger: updateSearchResultsSubject.eraseToAnyPublisher(),
                      updateMeasuringStateTrigger: updateMeasuringStateSubject
            .removeDuplicates()
            .eraseToAnyPublisher(),
                      clearSearchBarTrigger: clearSearchBarSubject.eraseToAnyPublisher()
        )
    }
}
