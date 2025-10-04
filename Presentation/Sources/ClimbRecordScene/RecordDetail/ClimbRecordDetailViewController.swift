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

final class ClimbRecordDetailViewController: UIViewController {

    var popVC: (() -> Void)?
    var pushVC: ((ClimbRecord) -> Void)?
    var isFromAddRecord: Bool = false

    private let mainView = ClimbRecordDetailView()
    let viewModel: ClimbRecordDetailViewModel
    private var cancellables = Set<AnyCancellable>()
    private lazy var dataSource = createDataSource()
    private let keyboardObserver = KeyboardHeightObserver()
    
    private var imageSelectedSubject = PassthroughSubject<Data, Error>()
    private var navBarSaveButtonSubject = PassthroughSubject<(Int, String), Never>()
    private let deleteSelectedSubject = PassthroughSubject<Void, Never>()
    
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
    }
    
    private func bind() {
        let saveButtonTap: AnyPublisher<(Int, String), Never> = mainView.saveButton.tap
            .compactMap { [weak self] in
                guard let self else { return nil }
                return (mainView.ratingView.rating, mainView.commentTextView.text)
            }
            .eraseToAnyPublisher()

        let input = ClimbRecordDetailViewModel.Input(
            editButtonTapped: mainView.editButton.tap,
            saveButtonTapped: saveButtonTap,
            cancelButtonTapped: mainView.cancelButton.tap,
            timelineButtonTapped: mainView.timelineButton.tap,
            deleteButtonTapped: mainView.deleteButton.tap,
            deleteSelected: deleteSelectedSubject.eraseToAnyPublisher(),
            editPhotoButtonTapped: mainView.editPhotoButton.tap,
            imageSelected: imageSelectedSubject.eraseToAnyPublisher(),
            navBarSaveButtonTapped: navBarSaveButtonSubject.eraseToAnyPublisher()
        )
        
        let output = viewModel.transform(input: input)
        
        output.recordEditable
            .sink { [weak self] isEditable in
                guard let self else { return }
                
                mainView.setEditable(isEditable)
            }
            .store(in: &cancellables)
        
        output.resetReview
            .sink { [weak self] (rating, comment) in
                self?.mainView.setReview(rating: rating, comment: comment)
            }
            .store(in: &cancellables)
        
        output.presentCancellableAlert
            .sink { [weak self] (title, message) in
                self?.presentCancellableAlert(title: title, message: message) {
                    self?.deleteSelectedSubject.send(())
                }
            }
            .store(in: &cancellables)
        
        output.popVC
            .sink { [weak self] in
                self?.popVC?()
            }
            .store(in: &cancellables)
        
        output.pushVC
            .sink { [weak self] climbRecord in
                self?.pushVC?(climbRecord)
            }
            .store(in: &cancellables)
        
        output.errorMessage
            .sink { errorMessage in
                print(errorMessage)
            }
            .store(in: &cancellables)

        output.timelineButtonEnabled
            .sink { [weak self] isEnabled in
                self?.mainView.setTimelineButtonEnabled(isEnabled)
            }
            .store(in: &cancellables)

        output.timelineButtonTitle
            .sink { [weak self] title in
                self?.mainView.setTimelineButtonTitle(title)
            }
            .store(in: &cancellables)

        output.presentPhotoActionSheet
            .sink { [weak self] hasImages in
                self?.presentPhotoActionSheet(hasImages: hasImages)
            }
            .store(in: &cancellables)

        output.saveCompleted
            .sink { [weak self] in
                self?.popVC?()
            }
            .store(in: &cancellables)

        configureView(viewModel.climbRecord)
    }

    private func configureView(_ climbRecord: ClimbRecord) {
        navigationItem.title = climbRecord.mountain.name

        mainView.setData(climbRecord: climbRecord)

        applySnapshot(images: climbRecord.images)
        mainView.pageControl.numberOfPages = climbRecord.images.count
        mainView.setEmptyImageViewHidden(!climbRecord.images.isEmpty)

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
            let deleteAction = UIAlertAction(title: "사진 삭제", style: .destructive) { _ in
                print("사진 삭제")
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
}

// MARK: - CollectionView SubMethods
extension ClimbRecordDetailViewController {
    
    private enum Section: CaseIterable {
        case main
    }
    
    private func createRegistration() -> UICollectionView.CellRegistration<ImageCollectionViewCell, String> {
        return UICollectionView.CellRegistration<ImageCollectionViewCell, String> { cell, indexPath, item in
            cell.setImage(image: item)
        }
    }
    
    private func createDataSource() -> UICollectionViewDiffableDataSource<Section, String> {
        let registration = createRegistration()
        return UICollectionViewDiffableDataSource<Section, String>(collectionView: mainView.imageCollectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
        }
    }
    
    private func applySnapshot(images: [String]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
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
                    print("✅ Image loaded successfully - size: \(image.size)")

                    // UIImage를 Data로 변환
                    guard let imageData = image.jpegData(compressionQuality: 0.8) else {
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

}
