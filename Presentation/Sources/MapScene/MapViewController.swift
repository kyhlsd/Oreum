//
//  MapViewController.swift
//  Presentation
//
//  Created by 김영훈 on 10/4/25.
//

import UIKit
import Combine
import MapKit
import Domain

final class MapViewController: UIViewController, BaseViewController {

    let mainView = MapView()
    let viewModel: MapViewModel
    
    private var cancellables = Set<AnyCancellable>()
    private lazy var dataSource = createDataSource()

    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()

    init(viewModel: MapViewModel) {
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

        setupNavItem()
        bind()

        viewDidLoadSubject.send(())
    }

    func bind() {
        let input = MapViewModel.Input(
            viewDidLoad: viewDidLoadSubject.eraseToAnyPublisher()
        )

        let output = viewModel.transform(input: input)

        output.userLocation
            .sink { [weak self] coordinate in
                self?.mainView.updateMapRegion(coordinate: coordinate)
            }
            .store(in: &cancellables)

        output.nearbyMountains
            .sink { [weak self] mountains in
                self?.applySnapshot(mountains: mountains)
            }
            .store(in: &cancellables)

        output.errorMessage
            .sink { errorMessage in
                print(errorMessage)
            }
            .store(in: &cancellables)
    }
    
    private func setupNavItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: NavTitleLabel(title: "내 주위 명산"))
        navigationItem.backButtonTitle = " "
    }
    
}

// MARK: - CollectionView SubMethods
extension MapViewController {
    
    private enum Section: CaseIterable {
        case main
    }

    private func createRegistration() -> UICollectionView.CellRegistration<NearbyMountainCollectionViewCell, MountainDistance> {
        return UICollectionView.CellRegistration<NearbyMountainCollectionViewCell, MountainDistance> { cell, indexPath, item in
            cell.configure(mountainLocation: item.mountainLocation, distance: item.distance)
        }
    }

    private func createDataSource() -> UICollectionViewDiffableDataSource<Section, MountainDistance> {
        let registration = createRegistration()
        return UICollectionViewDiffableDataSource<Section, MountainDistance>(collectionView: mainView.collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
        }
    }

    private func applySnapshot(mountains: [MountainDistance]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MountainDistance>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(mountains)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
}
