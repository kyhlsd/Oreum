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
        let errorMessage: AnyPublisher<(String, String), Never>
    }

    func transform(input: Input) -> Output {
        let recentSearchesSubject = PassthroughSubject<[String], Never>()
        let searchResultsSubject = PassthroughSubject<[MountainInfo], Never>()
        let errorMessageSubject = PassthroughSubject<(String, String), Never>()

        // 최근 검색어 Fetch
        let loadRecentSearchTrigger = PassthroughSubject<Void, Never>()

        loadRecentSearchTrigger
            .flatMap { [weak self] _ -> AnyPublisher<Result<[RecentSearch], Error>, Never> in
                guard let self else { return Just(.success([])).eraseToAnyPublisher() }
                return self.fetchRecentSearchesUseCase.execute()
            }
            .sink { result in
                switch result {
                case .success(let searches):
                    let keywords = searches.map { $0.keyword }
                    recentSearchesSubject.send(keywords)
                case .failure(let error):
                    errorMessageSubject.send(("최근 검색어 불러오기 실패", error.localizedDescription))
                    recentSearchesSubject.send([])
                }
            }
            .store(in: &cancellables)

        // viewDidLoad에서 최근 검색어 불러오기
        input.viewDidLoad
            .sink { _ in
                loadRecentSearchTrigger.send(())
            }
            .store(in: &cancellables)

        // 검색어 삭제
        input.deleteRecentSearch
            .flatMap { [weak self] keyword -> AnyPublisher<Result<Void, Error>, Never> in
                guard let self else { return Just(.success(())).eraseToAnyPublisher() }
                return self.deleteRecentSearchUseCase.execute(keyword: keyword)
            }
            .sink { result in
                switch result {
                case .success:
                    loadRecentSearchTrigger.send(())
                case .failure(let error):
                    errorMessageSubject.send(("최근 검색어 삭제 실패", error.localizedDescription))
                }
            }
            .store(in: &cancellables)

        // 검색어 모두 삭제
        input.clearAllRecentSearches
            .flatMap { [weak self] _ -> AnyPublisher<Result<Void, Error>, Never> in
                guard let self else { return Just(.success(())).eraseToAnyPublisher() }
                return self.clearRecentSearchesUseCase.execute()
            }
            .sink { result in
                switch result {
                case .success:
                    loadRecentSearchTrigger.send(())
                case .failure(let error):
                    errorMessageSubject.send(("최근 검색어 삭제 실패", error.localizedDescription))
                }
            }
            .store(in: &cancellables)

        // 검색하거나, 최근 검색어 눌렀을 때
        let searchPublisher = Publishers.Merge(
            input.searchText,
            input.recentSearchTapped
        )
        .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        .removeDuplicates()
        .flatMap { [weak self] keyword -> AnyPublisher<(String, [MountainInfo]), Never> in
            guard let self else { return Just((keyword, [])).eraseToAnyPublisher() }

            return self.fetchMountainsUseCase.execute(keyword: keyword)
                .map { (keyword, $0) }
                .catch { error -> Just<(String, [MountainInfo])> in
                    errorMessageSubject.send(("검색 결과 불러오기 실패", error.localizedDescription))
                    return Just((keyword, []))
                }
                .eraseToAnyPublisher()
        }
        .share()

        // 검색 결과 전송
        searchPublisher
            .sink { (keyword, results) in
                searchResultsSubject.send(results)
            }
            .store(in: &cancellables)

        // 최근 검색어 저장
        searchPublisher
            .map { $0.0 }
            .flatMap { [weak self] keyword -> AnyPublisher<Result<Void, Error>, Never> in
                guard let self else { return Just(.success(())).eraseToAnyPublisher() }
                return self.saveRecentSearchUseCase.execute(keyword: keyword)
            }
            .sink { result in
                switch result {
                case .success:
                    loadRecentSearchTrigger.send(())
                case .failure(let error):
                    errorMessageSubject.send(("최근 검색어 저장 실패", error.localizedDescription))
                }
            }
            .store(in: &cancellables)

        return Output(
            recentSearches: recentSearchesSubject.eraseToAnyPublisher(),
            searchResults: searchResultsSubject.eraseToAnyPublisher(),
            errorMessage: errorMessageSubject.eraseToAnyPublisher()
        )
    }
}
