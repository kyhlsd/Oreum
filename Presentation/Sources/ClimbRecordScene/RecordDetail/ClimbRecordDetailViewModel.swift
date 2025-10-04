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
    func updateImages(id: String, images: [String])
}

final class ClimbRecordDetailViewModel {

    private let updateUseCase: UpdateClimbRecordUseCase
    private let deleteUseCase: DeleteClimbRecordUseCase
    private let saveClimbRecordUseCase: SaveClimbRecordUseCase
    private let saveRecordImageUseCase: SaveRecordImageUseCase
    private let fetchRecordImageUseCase: FetchRecordImageUseCase
    private let deleteRecordImageUseCase: DeleteRecordImageUseCase
    private let addImageToRecordUseCase: AddImageToRecordUseCase
    private let removeImageFromRecordUseCase: RemoveImageFromRecordUseCase
    private var cancellables = Set<AnyCancellable>()

    private(set) var climbRecord: ClimbRecord
    private let isFromAddRecord: Bool
    weak var delegate: ClimbRecordDetailViewModelDelegate?
    private let saveCompletedSubject = PassthroughSubject<Void, Never>()

    init(updateUseCase: UpdateClimbRecordUseCase, deleteUseCase: DeleteClimbRecordUseCase, saveClimbRecordUseCase: SaveClimbRecordUseCase, saveRecordImageUseCase: SaveRecordImageUseCase, fetchRecordImageUseCase: FetchRecordImageUseCase, deleteRecordImageUseCase: DeleteRecordImageUseCase, addImageToRecordUseCase: AddImageToRecordUseCase, removeImageFromRecordUseCase: RemoveImageFromRecordUseCase, climbRecord: ClimbRecord, isFromAddRecord: Bool = false) {
        self.updateUseCase = updateUseCase
        self.deleteUseCase = deleteUseCase
        self.saveClimbRecordUseCase = saveClimbRecordUseCase
        self.saveRecordImageUseCase = saveRecordImageUseCase
        self.fetchRecordImageUseCase = fetchRecordImageUseCase
        self.deleteRecordImageUseCase = deleteRecordImageUseCase
        self.addImageToRecordUseCase = addImageToRecordUseCase
        self.removeImageFromRecordUseCase = removeImageFromRecordUseCase
        self.climbRecord = climbRecord
        self.isFromAddRecord = isFromAddRecord
    }
    
    struct Input {
        let editButtonTapped: AnyPublisher<Void, Never>
        let saveButtonTapped: AnyPublisher<(Int, String), Never>
        let cancelButtonTapped: AnyPublisher<Void, Never>
        let timelineButtonTapped: AnyPublisher<Void, Never>
        let deleteButtonTapped: AnyPublisher<Void, Never>
        let deleteSelected: AnyPublisher<Void, Never>
        let editPhotoButtonTapped: AnyPublisher<Void, Never>
        let imageSelected: AnyPublisher<Data, Error>
        let navBarSaveButtonTapped: AnyPublisher<(Int, String), Never>
        let viewDidLoad: AnyPublisher<Void, Never>
        let imageDeleteButtonTapped: AnyPublisher<Void, Never>
        let imageDeleteSelected: AnyPublisher<String, Never>
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
        let imageSaved: AnyPublisher<String, Never>
        let imagesFetched: AnyPublisher<[Data], Never>
        let presentImageDeleteAlert: AnyPublisher<Void, Never>
        let imageDeleted: AnyPublisher<Void, Never>
    }
    
    func transform(input: Input) -> Output {
        let recordEditableSubject = CurrentValueSubject<Bool, Never>(false)
        let resetReviewSubject = PassthroughSubject<(Int, String), Never>()
        let presentCancellableAlertSubject = PassthroughSubject<(String, String), Never>()
        let popVCSubject = PassthroughSubject<Void, Never>()
        let pushVCSubject = PassthroughSubject<ClimbRecord, Never>()
        let errorMesssageSubject = PassthroughSubject<String, Never>()

        let presentPhotoActionSheetSubject = PassthroughSubject<Bool, Never>()
        let imageSavedSubject = PassthroughSubject<String, Never>()
        let presentImageDeleteAlertSubject = PassthroughSubject<Void, Never>()
        let imageDeletedSubject = PassthroughSubject<Void, Never>()

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

                // 기존 record인 경우에만 Realm 업데이트
                if !isFromAddRecord {
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
                } else {
                    // Add 화면에서는 메모리에만 저장
                    climbRecord.score = rating
                    climbRecord.comment = comment
                    return Just(()).eraseToAnyPublisher()
                }
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
            .flatMap { [weak self] in
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

        input.editPhotoButtonTapped
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] in
                guard let self else { return }
                let hasImages = !climbRecord.images.isEmpty
                presentPhotoActionSheetSubject.send(hasImages)
            }
            .store(in: &cancellables)

        input.imageSelected
            .catch { error -> Just<Data> in
                errorMesssageSubject.send(error.localizedDescription)
                print("❌ Image selection error: \(error.localizedDescription)")
                return Just(Data())
            }
            .flatMap { [weak self] imageData -> AnyPublisher<String, Never> in
                guard let self else { return Just("").eraseToAnyPublisher() }
                guard !imageData.isEmpty else { return Just("").eraseToAnyPublisher() }

                return saveRecordImageUseCase.execute(imageData: imageData)
                    .catch { error -> Just<String> in
                        print("❌ Failed to save image: \(error.localizedDescription)")
                        return Just("")
                    }
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] imageID in
                guard let self else { return }
                if !imageID.isEmpty {
                    print("✅ Image saved successfully with ID: \(imageID)")

                    // ClimbRecord의 images 배열에 추가
                    climbRecord.images.append(imageID)
                    delegate?.updateImages(id: climbRecord.id, images: climbRecord.images)
                    imageSavedSubject.send(imageID)

                    // 기존 ClimbRecord인 경우에만 즉시 Realm에 저장
                    if !isFromAddRecord {
                        addImageToRecordUseCase.execute(recordID: climbRecord.id, imageID: imageID)
                            .sink(
                                receiveCompletion: { completion in
                                    if case .failure(let error) = completion {
                                        print("❌ Failed to add image to record: \(error.localizedDescription)")
                                    }
                                },
                                receiveValue: { _ in
                                    print("✅ Image added to Realm record")
                                }
                            )
                            .store(in: &self.cancellables)
                    } else {
                        print("ℹ️ Image will be saved to Realm when record is saved")
                    }
                }
            }
            .store(in: &cancellables)

        input.navBarSaveButtonTapped
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] (rating, comment) in
                guard let self else { return }

                climbRecord.score = rating
                climbRecord.comment = comment

                saveClimbRecordUseCase.execute(record: climbRecord)
                    .sink(
                        receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                print("❌ Save error: \(error.localizedDescription)")
                            }
                        },
                        receiveValue: { [weak self] _ in
                            NotificationCenter.default.post(name: .climbRecordDidSave, object: nil)
                            self?.saveCompletedSubject.send(())
                        }
                    )
                    .store(in: &self.cancellables)
            }
            .store(in: &cancellables)

        input.imageDeleteButtonTapped
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .sink {
                presentImageDeleteAlertSubject.send(())
            }
            .store(in: &cancellables)

        input.imageDeleteSelected
            .flatMap { [weak self] imageID -> AnyPublisher<String, Never> in
                guard let self else { return Just("").eraseToAnyPublisher() }

                // ClimbRecord의 images 배열에서 제거
                if let index = climbRecord.images.firstIndex(of: imageID) {
                    climbRecord.images.remove(at: index)
                    delegate?.updateImages(id: climbRecord.id, images: climbRecord.images)
                }

                // 파일 삭제
                deleteRecordImageUseCase.execute(imageID: imageID)
                    .sink(
                        receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                print("❌ Failed to delete image file: \(error.localizedDescription)")
                            }
                        },
                        receiveValue: { _ in
                            print("✅ Image file deleted")
                        }
                    )
                    .store(in: &self.cancellables)

                // 기존 ClimbRecord인 경우에만 즉시 Realm에서 삭제
                if !isFromAddRecord {
                    removeImageFromRecordUseCase.execute(imageID: imageID)
                        .sink(
                            receiveCompletion: { completion in
                                if case .failure(let error) = completion {
                                    print("❌ Failed to remove image from record: \(error.localizedDescription)")
                                }
                            },
                            receiveValue: { _ in
                                print("✅ Image removed from Realm record")
                            }
                        )
                        .store(in: &self.cancellables)
                } else {
                    print("ℹ️ Image will be removed from Realm when record is saved")
                }

                return Just(imageID).eraseToAnyPublisher()
            }
            .sink { _ in
                imageDeletedSubject.send(())
            }
            .store(in: &cancellables)

        let imagesFetched = input.viewDidLoad
            .flatMap { [weak self] _ -> AnyPublisher<[Data], Never> in
                guard let self else { return Just([]).eraseToAnyPublisher() }
                let publishers = climbRecord.images.map { imageID in
                    self.fetchRecordImageUseCase.execute(imageID: imageID)
                        .catch { error -> Empty<Data, Never> in
                            print("❌ Failed to fetch image: \(error.localizedDescription)")
                            return Empty()
                        }
                        .eraseToAnyPublisher()
                }

                return Publishers.MergeMany(publishers)
                    .collect()
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        let hasTimeline = !climbRecord.timeLog.isEmpty
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
            saveCompleted: saveCompletedSubject.eraseToAnyPublisher(),
            imageSaved: imageSavedSubject.eraseToAnyPublisher(),
            imagesFetched: imagesFetched,
            presentImageDeleteAlert: presentImageDeleteAlertSubject.eraseToAnyPublisher(),
            imageDeleted: imageDeletedSubject.eraseToAnyPublisher()
        )
    }

    func fetchImages() -> AnyPublisher<[Data], Never> {
        let publishers = climbRecord.images.map { imageID in
            fetchRecordImageUseCase.execute(imageID: imageID)
                .catch { error -> Empty<Data, Never> in
                    print("❌ Failed to fetch image: \(error.localizedDescription)")
                    return Empty()
                }
                .eraseToAnyPublisher()
        }

        return Publishers.MergeMany(publishers)
            .collect()
            .eraseToAnyPublisher()
    }

}
