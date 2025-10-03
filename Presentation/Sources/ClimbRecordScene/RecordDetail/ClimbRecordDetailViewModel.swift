//
//  ClimbRecordDetailViewModel.swift
//  Presentation
//
//  Created by 김영훈 on 9/28/25.
//

import Foundation
import Combine
import Domain

protocol ClimbRecordDetailViewModelDelegate: AnyObject {
    func updateReview(id: String, rating: Int, comment: String)
    func deleteRecord(id: String)
}

final class ClimbRecordDetailViewModel {

    private let updateUseCase: UpdateClimbRecordUseCase
    private let deleteUseCase: DeleteClimbRecordUseCase
    private let saveClimbRecordUseCase: SaveClimbRecordUseCase?
    private var cancellables = Set<AnyCancellable>()

    private(set) var climbRecord: ClimbRecord
    weak var delegate: ClimbRecordDetailViewModelDelegate?
    private let saveCompletedSubject = PassthroughSubject<Void, Never>()

    init(updateUseCase: UpdateClimbRecordUseCase, deleteUseCase: DeleteClimbRecordUseCase, climbRecord: ClimbRecord, saveClimbRecordUseCase: SaveClimbRecordUseCase? = nil) {
        self.updateUseCase = updateUseCase
        self.deleteUseCase = deleteUseCase
        self.climbRecord = climbRecord
        self.saveClimbRecordUseCase = saveClimbRecordUseCase
    }
    
    struct Input {
        let editButtonTapped: AnyPublisher<Void, Never>
        let saveButtonTapped: AnyPublisher<(Int, String), Never>
        let cancelButtonTapped: AnyPublisher<Void, Never>
        let timelineButtonTapped: AnyPublisher<Void, Never>
        let deleteButtonTapped: AnyPublisher<Void, Never>
        let deleteSelected: AnyPublisher<Void, Never>
        let editPhotoButtonTapped: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let recordEditable: AnyPublisher<Bool, Never>
        let resetReview: AnyPublisher<(Int, String), Never>
        let presentCancellableAlert: AnyPublisher<(String, String), Never>
        let popVC: AnyPublisher<Void, Never>
        let pushVC: AnyPublisher<ClimbRecord, Never>
        let errorMessage: AnyPublisher<String, Never>
        let timelineButtonEnabled: AnyPublisher<Bool, Never>
        let timelineButtonTitle: AnyPublisher<String, Never>
        let presentPhotoActionSheet: AnyPublisher<Bool, Never>
        let saveCompleted: AnyPublisher<Void, Never>
    }
    
    func transform(input: Input) -> Output {
        let recordEditableSubject = CurrentValueSubject<Bool, Never>(false)
        let resetReviewSubject = PassthroughSubject<(Int, String), Never>()
        let presentCancellableAlertSubject = PassthroughSubject<(String, String), Never>()
        let popVCSubject = PassthroughSubject<Void, Never>()
        let pushVCSubject = PassthroughSubject<ClimbRecord, Never>()
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
                        delegate?.updateReview(id: climbRecord.id, rating: rating, comment: comment)
                    })
                    .catch { error in
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
        
        input.timelineButtonTapped
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] in
                guard let self else { return }
                pushVCSubject.send(climbRecord)
            }
            .store(in: &cancellables)
        
        input.deleteButtonTapped
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .sink {
                presentCancellableAlertSubject.send(("기록을 삭제하시겠습니까?", "삭제된 기록은 복구되지 않습니다."))
            }
            .store(in: &cancellables)
        
        input.deleteSelected
            .flatMap { [weak self, deleteUseCase] in
                guard let self else { return Just(()).eraseToAnyPublisher() }
                return deleteUseCase.execute(recordID: climbRecord.id)
                    .catch { error in
                        errorMesssageSubject.send(error.localizedDescription)
                        return Just(())
                    }
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] in
                guard let self else { return }
                delegate?.deleteRecord(id: climbRecord.id)
                popVCSubject.send(())
            }
            .store(in: &cancellables)

        let presentPhotoActionSheetSubject = PassthroughSubject<Bool, Never>()

        input.editPhotoButtonTapped
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] in
                guard let self else { return }
                let hasImages = !climbRecord.images.isEmpty
                presentPhotoActionSheetSubject.send(hasImages)
            }
            .store(in: &cancellables)

        let hasTimeline = climbRecord.timeLog.count > 1
        let timelineButtonEnabled = Just(hasTimeline).eraseToAnyPublisher()
        let timelineButtonTitle = Just(hasTimeline ? "타임라인 보기" : "측정 기록이 없습니다").eraseToAnyPublisher()

        return Output(
            recordEditable: recordEditableSubject.eraseToAnyPublisher(),
            resetReview: resetReviewSubject.eraseToAnyPublisher(),
            presentCancellableAlert: presentCancellableAlertSubject.eraseToAnyPublisher(),
            popVC: popVCSubject.eraseToAnyPublisher(),
            pushVC: pushVCSubject.eraseToAnyPublisher(),
            errorMessage: errorMesssageSubject.eraseToAnyPublisher(),
            timelineButtonEnabled: timelineButtonEnabled,
            timelineButtonTitle: timelineButtonTitle,
            presentPhotoActionSheet: presentPhotoActionSheetSubject.eraseToAnyPublisher(),
            saveCompleted: saveCompletedSubject.eraseToAnyPublisher()
        )
    }

    func saveRecord(rating: Int, comment: String) {
        guard let saveClimbRecordUseCase else { return }

        climbRecord.score = rating
        climbRecord.comment = comment

        saveClimbRecordUseCase.execute(record: climbRecord)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Save error: \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] _ in
                    NotificationCenter.default.post(name: .climbRecordDidSave, object: nil)
                    self?.saveCompletedSubject.send(())
                }
            )
            .store(in: &cancellables)
    }
}
