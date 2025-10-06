//
//  SearchViewModel.swift
//  Presentation
//
//  Created by 김영훈 on 10/6/25.
//

import Foundation
import Combine
import Domain

final class SearchViewModel: BaseViewModel {

    private let fetchMountainsUseCase: FetchMountainsUseCase
    private var cancellables = Set<AnyCancellable>()

    init(fetchMountainsUseCase: FetchMountainsUseCase) {
        self.fetchMountainsUseCase = fetchMountainsUseCase
    }

    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let searchText: AnyPublisher<String, Never>
        let recentSearchTapped: AnyPublisher<String, Never>
        let deleteRecentSearch: AnyPublisher<String, Never>
        let clearAllRecentSearches: AnyPublisher<Void, Never>
    }

    struct Output {
        let recentSearches: AnyPublisher<[String], Never>
        let searchResults: AnyPublisher<[MountainInfo], Never>
        let errorMessage: AnyPublisher<String, Never>
    }

    func transform(input: Input) -> Output {
        let recentSearchesSubject = PassthroughSubject<[String], Never>()
        let searchResultsSubject = PassthroughSubject<[MountainInfo], Never>()
        let errorMessageSubject = PassthroughSubject<String, Never>()

        // 더미 최근 검색어
        var currentRecentSearches = ["북한산", "설악산", "한라산"]

        input.viewDidLoad
            .sink {
                recentSearchesSubject.send(currentRecentSearches)
            }
            .store(in: &cancellables)

        input.deleteRecentSearch
            .sink { searchToDelete in
                currentRecentSearches.removeAll { $0 == searchToDelete }
                recentSearchesSubject.send(currentRecentSearches)
            }
            .store(in: &cancellables)

        input.clearAllRecentSearches
            .sink {
                currentRecentSearches.removeAll()
                recentSearchesSubject.send(currentRecentSearches)
            }
            .store(in: &cancellables)

        let searchPublisher = Publishers.Merge(
            input.searchText,
            input.recentSearchTapped
        )

        searchPublisher
            .filter { !$0.isEmpty }
            .flatMap { [weak self] keyword -> AnyPublisher<[MountainInfo], Never> in
                guard let self else { return Just([]).eraseToAnyPublisher() }

                return self.fetchMountainsUseCase.execute(keyword: keyword)
                    .catch { error -> Just<[MountainInfo]> in
                        errorMessageSubject.send(error.localizedDescription)
                        return Just([])
                    }
                    .eraseToAnyPublisher()
            }
            .sink { results in
                searchResultsSubject.send(results)
            }
            .store(in: &cancellables)

        return Output(
            recentSearches: recentSearchesSubject.eraseToAnyPublisher(),
            searchResults: searchResultsSubject.eraseToAnyPublisher(),
            errorMessage: errorMessageSubject.eraseToAnyPublisher()
        )
    }
}
