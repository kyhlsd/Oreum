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
    }
    
    struct Output {
        let climbRecordList: AnyPublisher<[ClimbRecord], Never>
        let guideText: AnyPublisher<String, Never>
        let errorMessage: AnyPublisher<String, Never>
    }
    
    private let useCase: FetchClimbRecordUseCase
    private var cancellables = Set<AnyCancellable>()
    
    private let baseGuideText = "산을 눌러 자세한 정보를 확인하세요"
    
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
        
        let climbRecordList = Publishers.Merge(total, searched)
            .eraseToAnyPublisher()
        
        return Output(climbRecordList: climbRecordList,
                      guideText: guideTextSubject.eraseToAnyPublisher(),
                      errorMessage: errorMessageSubject.eraseToAnyPublisher()
        )
    }
}
