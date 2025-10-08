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
    private let fetchRecentSearchesUseCase: FetchRecentSearchesUseCase
    private let saveRecentSearchUseCase: SaveRecentSearchUseCase
    private let deleteRecentSearchUseCase: DeleteRecentSearchUseCase
    private let clearRecentSearchesUseCase: ClearRecentSearchesUseCase
    private var cancellables = Set<AnyCancellable>()

    init(
        fetchMountainsUseCase: FetchMountainsUseCase,
        fetchRecentSearchesUseCase: FetchRecentSearchesUseCase,
        saveRecentSearchUseCase: SaveRecentSearchUseCase,
        deleteRecentSearchUseCase: DeleteRecentSearchUseCase,
        clearRecentSearchesUseCase: ClearRecentSearchesUseCase
    ) {
        self.fetchMountainsUseCase = fetchMountainsUseCase
        self.fetchRecentSearchesUseCase = fetchRecentSearchesUseCase
        self.saveRecentSearchUseCase = saveRecentSearchUseCase
        self.deleteRecentSearchUseCase = deleteRecentSearchUseCase
        self.clearRecentSearchesUseCase = clearRecentSearchesUseCase
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

        let loadRecentSearchTrigger = PassthroughSubject<Void, Never>()

        loadRecentSearchTrigger
            .flatMap { [weak self] _ -> AnyPublisher<[String], Never> in
                guard let self else { return Just([]).eraseToAnyPublisher() }
                return self.fetchRecentSearchesUseCase.execute()
                    .map { $0.map { $0.keyword } }
                    .catch { error -> Just<[String]> in
                        errorMessageSubject.send(error.localizedDescription)
                        return Just([])
                    }
                    .eraseToAnyPublisher()
            }
            .sink { keywords in
                recentSearchesSubject.send(keywords)
            }
            .store(in: &cancellables)

        input.viewDidLoad
            .sink { _ in
                loadRecentSearchTrigger.send(())
            }
            .store(in: &cancellables)

        input.deleteRecentSearch
            .flatMap { [weak self] keyword -> AnyPublisher<Void, Never> in
                guard let self else { return Just(()).eraseToAnyPublisher() }
                return self.deleteRecentSearchUseCase.execute(keyword: keyword)
                    .catch { error -> Just<Void> in
                        errorMessageSubject.send(error.localizedDescription)
                        return Just(())
                    }
                    .eraseToAnyPublisher()
            }
            .sink { _ in
                loadRecentSearchTrigger.send(())
            }
            .store(in: &cancellables)

        input.clearAllRecentSearches
            .flatMap { [weak self] _ -> AnyPublisher<Void, Never> in
                guard let self else { return Just(()).eraseToAnyPublisher() }
                return self.clearRecentSearchesUseCase.execute()
                    .catch { error -> Just<Void> in
                        errorMessageSubject.send(error.localizedDescription)
                        return Just(())
                    }
                    .eraseToAnyPublisher()
            }
            .sink { _ in
                loadRecentSearchTrigger.send(())
            }
            .store(in: &cancellables)

        let searchPublisher = Publishers.Merge(
            input.searchText,
            input.recentSearchTapped
        )

        searchPublisher
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .removeDuplicates()
            .flatMap { [weak self] keyword -> AnyPublisher<(String, [MountainInfo]), Never> in
                guard let self else { return Just((keyword, [])).eraseToAnyPublisher() }

                return self.fetchMountainsUseCase.execute(keyword: keyword)
                    .map { (keyword, $0) }
                    .catch { error -> Just<(String, [MountainInfo])> in
                        errorMessageSubject.send(error.localizedDescription)
                        return Just((keyword, []))
                    }
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] (keyword, results) in
                guard let self else { return }

                // 검색 결과 전송
                searchResultsSubject.send(results)

                // 최근 검색어 저장 및 새로고침
                self.saveRecentSearchUseCase.execute(keyword: keyword)
                    .catch { error -> Just<Void> in
                        errorMessageSubject.send(error.localizedDescription)
                        return Just(())
                    }
                    .sink { _ in
                        loadRecentSearchTrigger.send(())
                    }
                    .store(in: &self.cancellables)
            }
            .store(in: &cancellables)

        return Output(
            recentSearches: recentSearchesSubject.eraseToAnyPublisher(),
            searchResults: searchResultsSubject.eraseToAnyPublisher(),
            errorMessage: errorMessageSubject.eraseToAnyPublisher()
        )
    }
}
