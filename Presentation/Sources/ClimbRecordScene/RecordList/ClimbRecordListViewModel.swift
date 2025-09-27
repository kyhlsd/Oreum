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
    
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let searchText: AnyPublisher<String, Never>
        let bookmarkTap: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let climbRecordList: AnyPublisher<[ClimbRecord], Never>
        let guideText: AnyPublisher<String, Never>
        let isOnlyBookmarked: AnyPublisher<Bool, Never>
        let errorMessage: AnyPublisher<String, Never>
    }
    
    private let useCase: FetchClimbRecordUseCase
    private var cancellables = Set<AnyCancellable>()
    
    private let baseGuideText = "산을 눌러 자세한 정보를 확인하세요"
    private var showOnlyBookmarked = false
    
    init(useCase: FetchClimbRecordUseCase) {
        self.useCase = useCase
    }
    
    func transform(input: Input) -> Output {
        let errorMessageSubject = PassthroughSubject<String, Never>()
        let guideTextSubject = CurrentValueSubject<String, Never>(baseGuideText)
        
        let total = input.viewDidLoad
            .flatMap { [useCase] in
                useCase.execute()
                    .catch { error -> Just<[ClimbRecord]> in
                        errorMessageSubject.send(error.localizedDescription)
                        return Just([])
                    }
            }
        
        let searched = input.searchText
            .debounce(for: .seconds(0.3), scheduler: RunLoop.main)
            .removeDuplicates()
            .flatMap { [useCase] keyword in
                useCase.search(keyword: keyword)
                    .catch { error -> Just<[ClimbRecord]> in
                        errorMessageSubject.send(error.localizedDescription)
                        return Just([])
                    }
            }
        
        let isOnlyBookmarked = input.bookmarkTap
            .scan(false) { last, _ in !last }
            .prepend(false)
            .eraseToAnyPublisher()
        
        let climbRecordList = Publishers.CombineLatest(Publishers.Merge(total, searched), isOnlyBookmarked)
            .map { [weak self] list, isBookmarkOnly in
                guard let self else { return list }
                
                var list = list
                if isBookmarkOnly {
                    list = list.filter { $0.isBookmarked }
                    guideTextSubject.send("북마크한 산들 (\(list.count)개)")
                } else {
                    guideTextSubject.send("\(baseGuideText) (\(list.count)개)")
                }
                return list
            }
            .eraseToAnyPublisher()
        
            
        
        return Output(climbRecordList: climbRecordList,
                      guideText: guideTextSubject.eraseToAnyPublisher(),
                      isOnlyBookmarked: isOnlyBookmarked,
                      errorMessage: errorMessageSubject.eraseToAnyPublisher()
        )
    }
}
