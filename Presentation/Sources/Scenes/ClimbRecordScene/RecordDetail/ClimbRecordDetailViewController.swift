//
//  ClimbRecordDetailViewController.swift
//  Presentation
//
//  Created by 김영훈 on 9/28/25.
//

import UIKit
import Combine
import Domain
import PhotosUI

final class ClimbRecordDetailViewController: UIViewController, BaseViewController {

    var popVC: (() -> Void)?
    var pushVC: ((ClimbRecord) -> Void)?
    var isFromAddRecord: Bool = false

    let mainView = ClimbRecordDetailView()
    let viewModel: ClimbRecordDetailViewModel
    private var cancellables = Set<AnyCancellable>()
    private lazy var dataSource = createDataSource()
    private let keyboardObserver = KeyboardHeightObserver()
    
    private var imageSelectedSubject = PassthroughSubject<Data, Error>()
    private var navBarSaveButtonSubject = PassthroughSubject<(Int, String), Never>()
    private let deleteSelectedSubject = PassthroughSubject<Void, Never>()
    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    private let imageDeleteButtonTappedSubject = PassthroughSubject<Void, Never>()
    private let imageDeleteSelectedSubject = PassthroughSubject<String, Never>()
    private let commentTextViewDidBeginEditing = PassthroughSubject<String, Never>()
    private let commentTextViewDidEndEditing = PassthroughSubject<String, Never>()
    
    init(viewModel: ClimbRecordDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
        setupNavItem()
        setupDelegates()
        setupKeyboardAction()

        viewDidLoadSubject.send(())
    }

    
    func bind() {
        let saveButtonTap: AnyPublisher<(Int, String), Never> = mainView.saveButton.tap
            .compactMap { [weak self] in
                guard let self else { return nil }
                return (mainView.ratingView.rating, mainView.commentTextView.text)
            }
            .eraseToAnyPublisher()

        let input = ClimbRecordDetailViewModel.Input(
            viewDidLoad: viewDidLoadSubject.eraseToAnyPublisher(),
            editButtonTapped: mainView.editButton.tap,
            saveButtonTapped: saveButtonTap,
            cancelButtonTapped: mainView.cancelButton.tap,
            timelineButtonTapped: mainView.timelineButton.tap,
            deleteButtonTapped: mainView.deleteButton.tap,
            deleteSelected: deleteSelectedSubject.eraseToAnyPublisher(),
            editPhotoButtonTapped: mainView.editPhotoButton.tap,
            imageSelected: imageSelectedSubject.eraseToAnyPublisher(),
            navBarSaveButtonTapped: navBarSaveButtonSubject.eraseToAnyPublisher(),
            imageDeleteButtonTapped: imageDeleteButtonTappedSubject.eraseToAnyPublisher(),
            imageDeleteSelected: imageDeleteSelectedSubject.eraseToAnyPublisher(),
            commentTextViewDidBeginEditing: commentTextViewDidBeginEditing.eraseToAnyPublisher(),
            commentTextViewDidEndEditing: commentTextViewDidEndEditing.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        
        // 후기 수정 가능 여부
        output.recordEditable
            .sink { [weak self] isEditable in
                guard let self else { return }
                
                mainView.setEditable(isEditable)
            }
            .store(in: &cancellables)
        
        // 후기 수정 취소 시 Reset
        output.resetReview
            .sink { [weak self] (rating, comment) in
                self?.mainView.setReview(rating: rating, comment: comment)
            }
            .store(in: &cancellables)
        
        // 기록 삭제 Alert
        output.presentCancellableAlert
            .sink { [weak self] (title, message) in
                self?.presentCancellableAlert(title: title, message: message) {
                    self?.deleteSelectedSubject.send(())
                }
            }
            .store(in: &cancellables)
        
        // pop
        output.popVC
            .sink { [weak self] in
                self?.popVC?()
            }
            .store(in: &cancellables)
        
        // ActivityLog로 push
        output.pushVC
            .sink { [weak self] climbRecord in
                self?.pushVC?(climbRecord)
            }
            .store(in: &cancellables)
        
        // ErrorAlert
        output.errorMessage
            .sink { [weak self] (title, message) in
                self?.presentDefaultAlert(title: title, message: message)
            }
            .store(in: &cancellables)

        // 타임라인 버튼 활성화/비활성화
        output.timelineButtonEnabled
            .sink { [weak self] isEnabled in
                self?.mainView.setTimelineButtonEnabled(isEnabled)
            }
            .store(in: &cancellables)

        // 타임라인 버튼 여부에 따른 제목
        output.timelineButtonTitle
            .sink { [weak self] title in
                self?.mainView.setTimelineButtonTitle(title)
            }
            .store(in: &cancellables)

        // 사진 편집 ActionSheet
        output.presentPhotoActionSheet
            .sink { [weak self] hasImages in
                self?.presentPhotoActionSheet(hasImages: hasImages)
            }
            .store(in: &cancellables)

        // 저장 완료 시 Pop
        output.saveCompleted
            .sink { [weak self] in
                self?.popVC?()
            }
            .store(in: &cancellables)

        // 이미지 목록 업데이트
        output.imagesFetched
            .sink { [weak self] imageDatas in
                guard let self else { return }
                applySnapshot(images: imageDatas)
                mainView.pageControl.numberOfPages = imageDatas.count
                mainView.setEmptyViewHidden(!imageDatas.isEmpty)
            }
            .store(in: &cancellables)

        output.presentImageDeleteAlert
            .sink { [weak self] in
                self?.presentImageDeleteAlert()
            }
            .store(in: &cancellables)
        
        output.placeholderState
            .sink { [weak self] state in
                guard let self else { return }
                mainView.setPlaceholder(isPlaceholder: state.isPlaceholder, text: state.text)
            }
            .store(in: &cancellables)
        
        configureView(viewModel.climbRecord)
    }

    private func configureView(_ climbRecord: ClimbRecord) {
        navigationItem.title = climbRecord.mountain.name

        mainView.setData(climbRecord: climbRecord)

        if isFromAddRecord {
            mainView.configureForAddRecord()
        }
    }
    
    private func setupNavItem() {
        navigationItem.backButtonTitle = " "

        if isFromAddRecord {
            let saveButton = UIBarButtonItem(title: "저장", style: .plain, target: self, action: #selector(saveButtonTapped))
            saveButton.tintColor = AppColor.primary
            navigationItem.rightBarButtonItem = saveButton

            navigationController?.navigationBar.tintColor = AppColor.primary
        }
    }

    @objc private func saveButtonTapped() {
        let rating = mainView.ratingView.rating
        let comment = mainView.commentTextView.text ?? ""
        navBarSaveButtonSubject.send((rating, comment))
    }
    
    private func setupDelegates() {
        mainView.commentTextView.delegate = self
    }
    
    private func setupKeyboardAction() {
        keyboardObserver.didKeyboardHeightChange = { [weak self] height in
            self?.mainView.adjustForKeyboard(height: height)
        }
    }

    private func presentPhotoActionSheet(hasImages: Bool) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let addAction = UIAlertAction(title: "사진 추가", style: .default) { [weak self] _ in
            self?.presentPhotoPicker()
        }
        alert.addAction(addAction)

        if hasImages {
            let deleteAction = UIAlertAction(title: "사진 삭제", style: .destructive) { [weak self] _ in
                self?.imageDeleteButtonTappedSubject.send(())
            }
            alert.addAction(deleteAction)
        }

        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

    private func presentPhotoPicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0
        configuration.filter = .images

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func presentImageDeleteAlert() {
        let currentPage = mainView.pageControl.currentPage

        let imageID: String
        if isFromAddRecord {
            // Add 화면에서는 pending_X 형태의 ID 사용
            imageID = "pending_\(currentPage)"
        } else {
            // 기존 record는 실제 imageID 사용
            guard currentPage < viewModel.climbRecord.images.count else { return }
            imageID = viewModel.climbRecord.images[currentPage]
        }

        let alert = UIAlertController(title: "사진 삭제", message: "이 사진을 삭제하시겠습니까?", preferredStyle: .alert)

        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.imageDeleteSelectedSubject.send(imageID)
        }
        alert.addAction(deleteAction)

        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
}

// MARK: - CollectionView SubMethods
extension ClimbRecordDetailViewController {
    
    private enum Section: CaseIterable {
        case main
    }
    
    private func createRegistration() -> UICollectionView.CellRegistration<ImageCollectionViewCell, Data> {
        return UICollectionView.CellRegistration<ImageCollectionViewCell, Data> { cell, indexPath, item in
            cell.setImage(imageData: item)
        }
    }

    private func createDataSource() -> UICollectionViewDiffableDataSource<Section, Data> {
        let registration = createRegistration()
        return UICollectionViewDiffableDataSource<Section, Data>(collectionView: mainView.imageCollectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
        }
    }

    private func applySnapshot(images: [Data]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Data>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(images)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - PHPickerViewControllerDelegate
extension ClimbRecordDetailViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard !results.isEmpty else { return }

        let converter = ImageDataManager(width: view.frame.width)
        
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self?.imageSelectedSubject.send(completion: .failure(error))
                    }
                    return
                }

                guard let image = object as? UIImage else { return }

                DispatchQueue.main.async { [weak self] in

                    guard let imageData = converter.process(image, format: .jpeg(quality: 1.0)) else {
                        let conversionError = NSError(domain: "ClimbRecordDetailViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
                        self?.imageSelectedSubject.send(completion: .failure(conversionError))
                        return
                    }

                    self?.imageSelectedSubject.send(imageData)
                }
            }
        }
    }
}

// MARK: - TextViewDelegate
extension ClimbRecordDetailViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        let maxHeight: CGFloat = 144
        let fittingSize = CGSize(width: textView.bounds.width, height: .greatestFiniteMagnitude)
        let size = textView.sizeThatFits(fittingSize)

        textView.isScrollEnabled = size.height > maxHeight
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if let text = textView.text {
            commentTextViewDidBeginEditing.send(text)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let text = textView.text {
            commentTextViewDidEndEditing.send(text)
        }
    }
}
