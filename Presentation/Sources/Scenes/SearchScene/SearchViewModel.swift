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

    private let searchMountainUseCase: SearchMountainUseCase
    private let fetchRecentSearchesUseCase: FetchRecentSearchesUseCase
    private let saveRecentSearchUseCase: SaveRecentSearchUseCase
    private let deleteRecentSearchUseCase: DeleteRecentSearchUseCase
    private let clearRecentSearchesUseCase: ClearRecentSearchesUseCase
    private var cancellables = Set<AnyCancellable>()

    init(
        searchMountainUseCase: SearchMountainUseCase,
        fetchRecentSearchesUseCase: FetchRecentSearchesUseCase,
        saveRecentSearchUseCase: SaveRecentSearchUseCase,
        deleteRecentSearchUseCase: DeleteRecentSearchUseCase,
        clearRecentSearchesUseCase: ClearRecentSearchesUseCase
    ) {
        self.searchMountainUseCase = searchMountainUseCase
        self.fetchRecentSearchesUseCase = fetchRecentSearchesUseCase
        self.saveRecentSearchUseCase = saveRecentSearchUseCase
        self.deleteRecentSearchUseCase = deleteRecentSearchUseCase
        self.clearRecentSearchesUseCase = clearRecentSearchesUseCase
    }

    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let searchText: AnyPublisher<String, Never>
        let loadMoreTrigger: AnyPublisher<Void, Never>
        let recentSearchTapped: AnyPublisher<String, Never>
        let deleteRecentSearch: AnyPublisher<String, Never>
        let clearAllRecentSearches: AnyPublisher<Void, Never>
    }

    struct Output {
        let recentSearches: AnyPublisher<[String], Never>
        let searchResults: AnyPublisher<[MountainInfo], Never>
        let errorMessage: AnyPublisher<(String, String), Never>
        let isLoading: AnyPublisher<Bool, Never>
    }

    func transform(input: Input) -> Output {
        let recentSearchesSubject = PassthroughSubject<[String], Never>()
        let searchResultsSubject = PassthroughSubject<[MountainInfo], Never>()
        let errorMessageSubject = PassthroughSubject<(String, String), Never>()
        let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)

        // 페이지네이션 상태
        let currentPageSubject = CurrentValueSubject<Int, Never>(1)
        let currentKeywordSubject = CurrentValueSubject<String, Never>("")
        let isLastPageSubject = CurrentValueSubject<Bool, Never>(false)
        let currentMountainsSubject = CurrentValueSubject<[MountainInfo], Never>([])

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
        let searchKeywordPublisher = Publishers.Merge(
            input.searchText,
            input.recentSearchTapped
        )
        .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        .share()

        // 새로운 검색 (중복 검색 방지)
        searchKeywordPublisher
            .removeDuplicates()
            .handleEvents(receiveOutput: { keyword in
                currentKeywordSubject.send(keyword)
                currentPageSubject.send(1)
                isLastPageSubject.send(false)
                isLoadingSubject.send(true)
            })
            .flatMap { [weak self] keyword -> AnyPublisher<Result<MountainResponse, Error>, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }

                return self.searchMountainUseCase.execute(keyword: keyword, page: 1)
                    .eraseToAnyPublisher()
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
                    errorMessageSubject.send(("검색 결과 불러오기 실패", error.localizedDescription))
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
                case .failure:
                    isLastPageSubject.send(true)
                }
            }
            .store(in: &cancellables)

        // 최근 검색어 저장
        searchKeywordPublisher
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
            errorMessage: errorMessageSubject.eraseToAnyPublisher(),
            isLoading: isLoadingSubject.eraseToAnyPublisher()
        )
    }
}
