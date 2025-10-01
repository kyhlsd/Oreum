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
    }

    struct Output {
        let searchResults: AnyPublisher<[MountainInfo], Never>
        let setMountainLabelTrigger: AnyPublisher<(String, String), Never>
        let setMountainBoxIsHiddenTrigger: AnyPublisher<Bool, Never>
        let setStartButtonEnabledTrigger: AnyPublisher<Bool, Never>
        let setSearchResultsOverlayIsHiddenTrigger: AnyPublisher<Bool, Never>
    }

    func transform(input: Input) -> Output {
        let mountainLabelSubject = PassthroughSubject<(String, String), Never>()
        let mountainBoxIsHiddenSubject = CurrentValueSubject<Bool, Never>(true)
        let startButtonEnabledSubject = CurrentValueSubject<Bool, Never>(false)
        let searchResultsOverlayIsHiddenSubject = PassthroughSubject<Bool, Never>()
        
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
                searchResultsOverlayIsHiddenSubject.send(results.isEmpty)
            }
            .store(in: &cancellables)

        input.selectMountain
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .sink { mountainInfo in
                mountainLabelSubject.send((mountainInfo.name, mountainInfo.address))
                mountainBoxIsHiddenSubject.send(false)
                startButtonEnabledSubject.send(true)
                searchResultsOverlayIsHiddenSubject.send(true)
            }
            .store(in: &cancellables)

        return Output(searchResults: searchResults,
                      setMountainLabelTrigger: mountainLabelSubject.eraseToAnyPublisher(),
                      setMountainBoxIsHiddenTrigger: mountainBoxIsHiddenSubject
            .removeDuplicates()
            .eraseToAnyPublisher(),
                      setStartButtonEnabledTrigger: startButtonEnabledSubject
            .removeDuplicates()
            .eraseToAnyPublisher(),
                      setSearchResultsOverlayIsHiddenTrigger: searchResultsOverlayIsHiddenSubject
            .eraseToAnyPublisher()
        )
    }
}
