//
//  ClimbRecordDetailViewModel.swift
//  Presentation
//
//  Created by 김영훈 on 9/28/25.
//

import Foundation
import Combine
import Domain

final class ClimbRecordDetailViewModel {
    
    private let updateUseCase: UpdateClimbRecordUseCase
    private let deleteUseCase: DeleteClimbRecordUseCase
    private var cancellables = Set<AnyCancellable>()
    
    private(set) var climbRecord: ClimbRecord
    
    init(updateUseCase: UpdateClimbRecordUseCase, deleteUseCase: DeleteClimbRecordUseCase, climbRecord: ClimbRecord) {
        self.updateUseCase = updateUseCase
        self.deleteUseCase = deleteUseCase
        self.climbRecord = climbRecord
    }
    
    struct Input {
        let editButtonTapped: AnyPublisher<Void, Never>
        let saveButtonTapped: AnyPublisher<(Int, String), Never>
        let cancelButtonTapped: AnyPublisher<Void, Never>
        let timelineButtonTapped: AnyPublisher<Void, Never>
        let deleteButtonTapped: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let recordEditable: AnyPublisher<Bool, Never>
        let resetReview: AnyPublisher<(Int, String), Never>
        let errorMessage: AnyPublisher<String, Never>
    }
    
    func transform(input: Input) -> Output {
        let recordEditableSubject = CurrentValueSubject<Bool, Never>(false)
        let resetReviewSubject = PassthroughSubject<(Int, String), Never>()
        let errorMesssageSubject = PassthroughSubject<String, Never>()
        
        input.editButtonTapped
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .sink {
                recordEditableSubject.send(true)
            }
            .store(in: &cancellables)
        
        input.saveButtonTapped
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .flatMap { [weak self, updateUseCase] (rating, comment) in
                guard let self else { return Just(()).eraseToAnyPublisher() }
                return updateUseCase.execute(recordID: climbRecord.id, rating: rating, comment: comment)
                    .handleEvents(receiveOutput: { [weak self] _ in
                        guard let self else { return }
                        climbRecord.score = rating
                        climbRecord.comment = comment
                    })
                    .catch { error -> Just<Void> in
                        errorMesssageSubject.send(error.localizedDescription)
                        return Just(())
                    }
                    .eraseToAnyPublisher()
            }
            .sink {
                recordEditableSubject.send(false)
            }
            .store(in: &cancellables)
        
        input.cancelButtonTapped
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] in
                guard let self else { return }
                recordEditableSubject.send(false)
                resetReviewSubject.send((climbRecord.score, climbRecord.comment))
            }
            .store(in: &cancellables)
        
        return Output(
            recordEditable: recordEditableSubject.eraseToAnyPublisher(),
            resetReview: resetReviewSubject.eraseToAnyPublisher(),
            errorMessage: errorMesssageSubject.eraseToAnyPublisher()
        )
    }
}
