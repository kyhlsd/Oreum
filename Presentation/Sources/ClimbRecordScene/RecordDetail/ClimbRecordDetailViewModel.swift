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
    private var pendingImages: [Data] = [] // Add 화면에서 선택한 이미지들을 임시 저장

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

                // 이미지 ID 목록 저장
                let imageIDs = climbRecord.images

                // 먼저 이미지 파일들 삭제
                let deleteImagePublishers = imageIDs.map { imageID in
                    self.deleteRecordImageUseCase.execute(imageID: imageID)
                        .catch { error -> Just<Void> in
                            print("❌ Failed to delete image file \(imageID): \(error.localizedDescription)")
                            return Just(())
                        }
                }

                return Publishers.MergeMany(deleteImagePublishers)
                    .collect()
                    .flatMap { _ in
                        // 이미지 파일 삭제 후 기록 삭제
                        self.deleteUseCase.execute(recordID: self.climbRecord.id)
                            .catch { error in
                                errorMesssageSubject.send(error.localizedDescription)
                                return Just(())
                            }
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
                let hasImages = isFromAddRecord ? !pendingImages.isEmpty : !climbRecord.images.isEmpty
                presentPhotoActionSheetSubject.send(hasImages)
            }
            .store(in: &cancellables)

        input.imageSelected
            .catch { error -> Just<Data> in
                errorMesssageSubject.send(error.localizedDescription)
                print("❌ Image selection error: \(error.localizedDescription)")
                return Just(Data())
            }
            .sink { [weak self] imageData in
                guard let self else { return }
                guard !imageData.isEmpty else { return }

                if isFromAddRecord {
                    // Add 화면에서는 이미지를 메모리에만 저장
                    pendingImages.append(imageData)
                    imageSavedSubject.send("pending_\(pendingImages.count - 1)")
                    print("ℹ️ Image stored in memory, will be saved when record is saved")
                } else {
                    // 기존 record인 경우 즉시 파일로 저장
                    saveRecordImageUseCase.execute(imageData: imageData)
                        .sink(
                            receiveCompletion: { completion in
                                if case .failure(let error) = completion {
                                    print("❌ Failed to save image: \(error.localizedDescription)")
                                }
                            },
                            receiveValue: { [weak self] imageID in
                                guard let self else { return }
                                print("✅ Image saved successfully with ID: \(imageID)")

                                climbRecord.images.append(imageID)
                                delegate?.updateImages(id: climbRecord.id, images: climbRecord.images)
                                imageSavedSubject.send(imageID)

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
                            }
                        )
                        .store(in: &self.cancellables)
                }
            }
            .store(in: &cancellables)

        input.navBarSaveButtonTapped
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] (rating, comment) in
                guard let self else { return }

                climbRecord.score = rating
                climbRecord.comment = comment

                // Add 화면에서 저장하는 경우, pending 이미지들을 먼저 저장
                if isFromAddRecord && !pendingImages.isEmpty {
                    let imagePublishers = pendingImages.map { imageData in
                        self.saveRecordImageUseCase.execute(imageData: imageData)
                    }

                    Publishers.MergeMany(imagePublishers)
                        .collect()
                        .flatMap { [weak self] imageIDs -> AnyPublisher<Void, Error> in
                            guard let self else { return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher() }

                            // 저장된 이미지 ID들을 ClimbRecord에 추가
                            self.climbRecord.images = imageIDs

                            return self.saveClimbRecordUseCase.execute(record: self.climbRecord)
                        }
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
                } else {
                    // 이미지가 없거나 기존 record인 경우 바로 저장
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
            }
            .store(in: &cancellables)

        input.imageDeleteButtonTapped
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .sink {
                presentImageDeleteAlertSubject.send(())
            }
            .store(in: &cancellables)

        input.imageDeleteSelected
            .sink { [weak self] imageID in
                guard let self else { return }

                if isFromAddRecord {
                    // Add 화면에서는 pendingImages에서 제거
                    if imageID.hasPrefix("pending_"),
                       let indexString = imageID.split(separator: "_").last,
                       let index = Int(indexString),
                       index < pendingImages.count {
                        pendingImages.remove(at: index)
                        print("ℹ️ Image removed from memory")
                    }
                } else {
                    // 기존 record는 파일과 Realm에서 삭제
                    if let index = climbRecord.images.firstIndex(of: imageID) {
                        climbRecord.images.remove(at: index)
                        delegate?.updateImages(id: climbRecord.id, images: climbRecord.images)
                    }

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
                }

                imageDeletedSubject.send(())
            }
            .store(in: &cancellables)

        let imagesFetched = input.viewDidLoad
            .flatMap { [weak self] _ -> AnyPublisher<[Data], Never> in
                guard let self else { return Just([]).eraseToAnyPublisher() }

                // Add 화면이면 pendingImages 반환
                if isFromAddRecord {
                    return Just(pendingImages).eraseToAnyPublisher()
                }

                // 기존 record면 파일에서 가져오기
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
        // Add 화면이면 pendingImages 반환
        if isFromAddRecord {
            return Just(pendingImages).eraseToAnyPublisher()
        }

        // 기존 record면 파일에서 가져오기
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

    func deleteImageFile(imageID: String) {
        deleteRecordImageUseCase.execute(imageID: imageID)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("❌ Failed to delete image file: \(error.localizedDescription)")
                    }
                },
                receiveValue: { _ in
                    print("✅ Unsaved image file deleted: \(imageID)")
                }
            )
            .store(in: &cancellables)
    }

}
