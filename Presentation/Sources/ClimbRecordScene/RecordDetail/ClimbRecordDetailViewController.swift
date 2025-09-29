//
//  ClimbRecordDetailViewController.swift
//  Presentation
//
//  Created by 김영훈 on 9/28/25.
//

import UIKit
import Combine
import Domain

final class ClimbRecordDetailViewController: UIViewController {
    
    var popVC: (() -> Void)?
    var pushVC: ((ClimbRecord) -> Void)?
    
    private let mainView = ClimbRecordDetailView()
    let viewModel: ClimbRecordDetailViewModel
    private var cancellables = Set<AnyCancellable>()
    private lazy var dataSource = createDataSource()
    private let keyboardObserver = KeyboardHeightObserver()
    
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
        let deleteSelectedSubject = PassthroughSubject<Void, Never>()
        
        let input = ClimbRecordDetailViewModel.Input(
            editButtonTapped: mainView.editButton.tap,
            saveButtonTapped: mainView.saveButtonTapped,
            cancelButtonTapped: mainView.cancelButton.tap,
            timelineButtonTapped: mainView.timelineButton.tap,
            deleteButtonTapped: mainView.deleteButton.tap,
            deleteSelected: deleteSelectedSubject.eraseToAnyPublisher()
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
                    deleteSelectedSubject.send(())
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
        
        configureView(viewModel.climbRecord)
    }
    
    private func configureView(_ climbRecord: ClimbRecord) {
        navigationItem.title = climbRecord.mountain.name
        
        mainView.setData(climbRecord: climbRecord)
        
        applySnapshot(images: climbRecord.images)
        mainView.pageControl.numberOfPages = climbRecord.images.count
    }
    
    private func setupNavItem() {
        navigationItem.backButtonTitle = " "
    }
    
    private func setupDelegates() {
        mainView.imageCollectionView.delegate = self
        mainView.commentTextView.delegate = self
    }
    
    private func setupKeyboardAction() {
        keyboardObserver.didKeyboardHeightChange = { [weak self] height in
            self?.mainView.adjustForKeyboard(height: height)
        }
    }
}

// MARK: - CollectionViewDelegate
extension ClimbRecordDetailViewController: UICollectionViewDelegate {
    
    private enum Section: CaseIterable {
        case main
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == mainView.imageCollectionView {
            print("mainView", mainView.imageCollectionView.bounds.width)
            let width = scrollView.bounds.width
            print(width)
            print(scrollView.contentOffset.x)
            guard width > 0 else { return }
            print("asdf")
            
            let page = Int(round(scrollView.contentOffset.x / width))
            mainView.pageControl.currentPage = page
        }
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

// MARK: - TextViewDelegate
extension ClimbRecordDetailViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let maxHeight: CGFloat = 144
        let fittingSize = CGSize(width: textView.bounds.width, height: .greatestFiniteMagnitude)
        let size = textView.sizeThatFits(fittingSize)
        
        textView.isScrollEnabled = size.height > maxHeight
    }
    
}
