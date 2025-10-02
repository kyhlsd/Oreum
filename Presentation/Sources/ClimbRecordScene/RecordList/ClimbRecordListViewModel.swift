//
//  ClimbRecordListViewModel.swift
//  Presentation
//
//  Created by 김영훈 on 9/27/25.
//

import Foundation
import Combine
import Domain

final class ClimbRecordListViewModel {
    
    private let fetchUseCase: FetchClimbRecordUseCase
    private let toggleBookmarkUseCase: ToggleBookmarkUseCase
    private var cancellables = Set<AnyCancellable>()
    
    private(set) var climbRecordList = [ClimbRecord]()
    private let baseGuideText = "산을 눌러 자세한 정보를 확인하세요."
    private let reloadDataSubject = PassthroughSubject<Void, Never>()
    private let emptyText = "+ 버튼으로 이전 기록을 추가하거나,\n측정 탭에서 기록을 측정하여 추가할 수 있습니다"
    
    init(fetchUseCase: FetchClimbRecordUseCase, toggleBookmarkUseCase: ToggleBookmarkUseCase) {
        self.fetchUseCase = fetchUseCase
        self.toggleBookmarkUseCase = toggleBookmarkUseCase
    }
    
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let searchText: AnyPublisher<String, Never>
        let bookmarkButtonTapped: AnyPublisher<Void, Never>
        let cellBookmarkButtonTapped: AnyPublisher<String, Never>
        let climbRecordDidSave: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let reloadData: AnyPublisher<Void, Never>
        let guideText: AnyPublisher<String, Never>
        let isOnlyBookmarked: AnyPublisher<Bool, Never>
        let bookmarkToggled: AnyPublisher<Int, Never>
        let errorMessage: AnyPublisher<String, Never>
        let emptyStateText: AnyPublisher<String, Never>
    }
    
    func transform(input: Input) -> Output {
        let guideTextSubject = CurrentValueSubject<String, Never>(baseGuideText)
        let errorMessageSubject = PassthroughSubject<String, Never>()
        let emptyStateTextSubject = CurrentValueSubject<String, Never>(emptyText)

        let searchTextSubject = CurrentValueSubject<String, Never>("")

        input.viewDidLoad
            .map { "" }
            .merge(with: input.searchText)
            .debounce(for: .seconds(0.3), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { searchTextSubject.send($0) }
            .store(in: &cancellables)

        let searchText = searchTextSubject.eraseToAnyPublisher()

        let isOnlyBookmarkedSubject = CurrentValueSubject<Bool, Never>(false)

        input.bookmarkButtonTapped
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .scan(false) { last, _ in !last }
            .sink { isOnlyBookmarkedSubject.send($0) }
            .store(in: &cancellables)

        let isOnlyBookmarked = isOnlyBookmarkedSubject.eraseToAnyPublisher()

        let immediateRefresh = input.climbRecordDidSave
            .map { _ in (searchTextSubject.value, isOnlyBookmarkedSubject.value) }

        let fetchTrigger = Publishers.Merge(
            Publishers.CombineLatest(searchText, isOnlyBookmarked),
            immediateRefresh
        )

        fetchTrigger
            .flatMap { [fetchUseCase] keyword, isOnlyBookmarked in
                fetchUseCase.execute(keyword: keyword, isOnlyBookmarked: isOnlyBookmarked)
                    .catch { error -> Just<[ClimbRecord]> in
                        errorMessageSubject.send(error.localizedDescription)
                        return Just([])
                    }
                    .map { ($0, keyword, isOnlyBookmarked)}
            }
            .sink { [weak self] (list, keyword, isOnlyBookmarked) in
                guard let self else { return }

                climbRecordList = list

                if isOnlyBookmarked {
                    guideTextSubject.send("북마크한 산들 (\(list.count)개)")
                } else {
                    guideTextSubject.send("\(baseGuideText) (\(list.count)개)")
                }

                if list.isEmpty {
                    if keyword.isEmpty {
                        emptyStateTextSubject.send(emptyText)
                    } else {
                        emptyStateTextSubject.send("검색 결과가 없습니다\n다른 키워드로 검색해보세요")
                    }
                }

                reloadDataSubject.send(())
            }
            .store(in: &cancellables)
        
        let bookmarkToggled = input.cellBookmarkButtonTapped
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .flatMap { [toggleBookmarkUseCase] id in
                toggleBookmarkUseCase.execute(recordID: id)
                    .compactMap { [weak self] in
                        if let index = self?.climbRecordList.firstIndex(where: { $0.id == id }) {
                            self?.climbRecordList[index].isBookmarked.toggle()
                            return index
                        }
                        return nil
                    }
                    .catch { error -> Just<Int> in
                        errorMessageSubject.send(error.localizedDescription)
                        return Just(-1)
                    }
            }
            .eraseToAnyPublisher()
        
        return Output(
            reloadData: reloadDataSubject.eraseToAnyPublisher(),
            guideText: guideTextSubject.eraseToAnyPublisher(),
            isOnlyBookmarked: isOnlyBookmarked,
            bookmarkToggled: bookmarkToggled,
            errorMessage: errorMessageSubject.eraseToAnyPublisher(),
            emptyStateText: emptyStateTextSubject.eraseToAnyPublisher()
        )
    }
}

// MARK: - ClimbRecordDetailViewModelDelegate
extension ClimbRecordListViewModel: ClimbRecordDetailViewModelDelegate {
    
    func updateReview(id: String, rating: Int, comment: String) {
        if let index = climbRecordList.firstIndex(where: {
            $0.id == id
        }) {
            climbRecordList[index].score = rating
            climbRecordList[index].comment = comment
        }
    }
    
    func deleteRecord(id: String) {
        if let index = climbRecordList.firstIndex(where: {
            $0.id == id
        }) {
            climbRecordList.remove(at: index)
            reloadDataSubject.send(())
        }
    }
}
