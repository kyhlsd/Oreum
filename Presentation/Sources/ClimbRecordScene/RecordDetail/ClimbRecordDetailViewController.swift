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
    
    private enum Section: CaseIterable {
        case main
    }
    
    private let mainView = ClimbRecordDetailView()
    private let viewModel: ClimbRecordDetailViewModel
    private var climbRecord: ClimbRecord
    private var cancellables = Set<AnyCancellable>()
    private lazy var dataSource = createDataSource()
    
    init(viewModel: ClimbRecordDetailViewModel, climbRecord: ClimbRecord) {
        self.viewModel = viewModel
        self.climbRecord = climbRecord
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
        
        mainView.pageControl.numberOfPages = climbRecord.images.count
    }
    
    private func bind() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(climbRecord.images)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func setupNavItem() {
        navigationItem.title = climbRecord.mountain.name
        navigationItem.backButtonTitle = " "
    }
    
    private func setupDelegates() {
        mainView.imageCollectionView.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension ClimbRecordDetailViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("mainView", mainView.imageCollectionView.bounds.width)
        let width = scrollView.bounds.width
        print(width)
        print(scrollView.contentOffset.x)
        guard width > 0 else { return }
        print("asdf")
        
        let page = Int(round(scrollView.contentOffset.x / width))
        mainView.pageControl.currentPage = page
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
}
