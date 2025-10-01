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
    }

    struct Output {
        let searchResults: AnyPublisher<[MountainInfo], Never>
        let updateMountainLabelsTrigger: AnyPublisher<(String, String), Never>
        let updateMountainBoxIsHiddenTrigger: AnyPublisher<Bool, Never>
        let updateStartButtonIsEnabledTrigger: AnyPublisher<Bool, Never>
        let updateSearchResultsOverlayIsHiddenTrigger: AnyPublisher<Bool, Never>
        let updateSearchResultsTrigger: AnyPublisher<Int, Never>
    }

    func transform(input: Input) -> Output {
        let updateMountainLabelsSubject = PassthroughSubject<(String, String), Never>()
        let updateMountainBoxIsHiddenSubject = CurrentValueSubject<Bool, Never>(true)
        let updateStartButtonIsEnabledSubject = CurrentValueSubject<Bool, Never>(false)
        let updateSearchResultsOverlayIsHiddenSubject = PassthroughSubject<Bool, Never>()
        let updateSearchResultsSubject = PassthroughSubject<Int, Never>()

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
            .sink {
                updateMountainBoxIsHiddenSubject.send(true)
                updateStartButtonIsEnabledSubject.send(false)
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
                      updateSearchResultsTrigger: updateSearchResultsSubject.eraseToAnyPublisher()
        )
    }
}
