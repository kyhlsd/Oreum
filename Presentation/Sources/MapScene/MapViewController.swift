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
            viewDidLoad: viewDidLoadSubject.eraseToAnyPublisher(),
            locationButtonTapped: mainView.currentLocationButton.tap
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
                self?.updateMapAnnotations(mountains: mountains)
            }
            .store(in: &cancellables)

        output.errorMessage
            .sink { errorMessage in
                print(errorMessage)
            }
            .store(in: &cancellables)

        output.showLocationPermissionAlert
            .sink { [weak self] in
                self?.presentCancellableAlert(title: "위치 권한 필요", message: "위치 권한이 거부되어 있습니다.\n설정으로 이동하시겠습니까?") {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }
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

    private func updateMapAnnotations(mountains: [MountainDistance]) {
        mainView.mapView.removeAnnotations(mainView.mapView.annotations)

        let annotations = mountains.map { mountain -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(
                latitude: mountain.mountainLocation.latitude,
                longitude: mountain.mountainLocation.longitude
            )
            annotation.title = mountain.mountainLocation.name
            annotation.subtitle = String(format: "%.1fkm", mountain.distance)
            return annotation
        }

        mainView.mapView.addAnnotations(annotations)
    }

}
