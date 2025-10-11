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

    var pushInfoVC: ((MountainInfo) -> Void)?

    let mainView = MapView()
    let viewModel: MapViewModel

    private var cancellables = Set<AnyCancellable>()
    private lazy var dataSource = createDataSource()

    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    private let mountainCellTappedSubject = PassthroughSubject<MountainDistance, Never>()
    private let mountainInfoButtonTappedSubject = PassthroughSubject<(String, Int), Never>()

    // Custom clustering
    private let annotationManager = MapAnnotationManager()
    private let annotationViewBuilder = MapAnnotationViewBuilder()
    private let regionDidChangeSubject = PassthroughSubject<Void, Never>()
    private var lastAltitude: CLLocationDistance = 0

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
        setupDelegates()
        setupMapBoundary()
        setupAnnotationViewBuilder()
        bind()

        viewDidLoadSubject.send(())
    }

    private func setupAnnotationViewBuilder() {
        annotationViewBuilder.onMountainInfoButtonTapped = { [weak self] name, height in
            self?.mountainInfoButtonTappedSubject.send((name, height))
        }
    }

    func bind() {
        let input = MapViewModel.Input(
            viewDidLoad: viewDidLoadSubject.eraseToAnyPublisher(),
            locationButtonTapped: mainView.currentLocationButton.tap,
            mountainCellTapped: mountainCellTappedSubject.eraseToAnyPublisher(),
            searchText: mainView.searchBar.textDidChange,
            mountainInfoButtonTapped: mountainInfoButtonTappedSubject.eraseToAnyPublisher()
        )

        let output = viewModel.transform(input: input)

        output.userLocation
            .sink { [weak self] coordinate in
                self?.mainView.updateMapRegion(coordinate: coordinate)
            }
            .store(in: &cancellables)

        output.displayMountains
            .sink { [weak self] mountains in
                self?.applySnapshot(mountains: mountains)
                self?.mainView.showEmptyState(mountains.isEmpty)
                self?.mainView.collectionView.setContentOffset(.zero, animated: false)
            }
            .store(in: &cancellables)

        output.allMountains
            .sink { [weak self] mountains in
                self?.annotationManager.updateMountains(mountains)
                self?.updateClusteredAnnotations()
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

        output.moveToMountainLocation
            .sink { [weak self] coordinate in
                self?.mainView.updateMapRegion(coordinate: coordinate)
            }
            .store(in: &cancellables)
        
        output.pushMountainInfo
            .sink { [weak self] mountainInfo in
                self?.pushInfoVC?(mountainInfo)
            }
            .store(in: &cancellables)

        // 지도 영역 변경 debounce
        regionDidChangeSubject
            .debounce(for: .seconds(0.3), scheduler: RunLoop.main)
            .sink { [weak self] in
                self?.updateClusteredAnnotations()
            }
            .store(in: &cancellables)
    }
    
    private func setupNavItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: NavTitleLabel(title: "명산 지도"))
        navigationItem.backButtonTitle = " "
    }
    
    private func setupDelegates() {
        mainView.collectionView.delegate = self
        mainView.mapView.delegate = self
        mainView.searchBar.delegate = self
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

    private func updateClusteredAnnotations() {
        let (toAdd, toRemove) = annotationManager.updateAnnotations(on: mainView.mapView)

        // 변경사항이 있을 때만 업데이트
        if !toRemove.isEmpty || !toAdd.isEmpty {
            mainView.mapView.removeAnnotations(toRemove)
            mainView.mapView.addAnnotations(toAdd)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

}

// MARK: - UICollectionViewDelegate
extension MapViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let mountain = dataSource.itemIdentifier(for: indexPath) else { return }
        mountainCellTappedSubject.send(mountain)
    }
}

// MARK: - MKMapViewDelegate + SubMethods
extension MapViewController: MKMapViewDelegate {

    private enum MapConfig {
        static let southKoreaCenter = CLLocationCoordinate2D(latitude: 36.5, longitude: 127.5)
        static let regionLatitudinalMeters: CLLocationDistance = 800000
        static let regionLongitudinalMeters: CLLocationDistance = 500000
        static let minZoomDistance: CLLocationDistance = 5000
        static let maxZoomDistance: CLLocationDistance = 1000000
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let currentAltitude = mapView.camera.altitude

        // altitude 변화가 있을 때만 재클러스터링
        let altitudeDifference = abs(currentAltitude - lastAltitude)
        let altitudeChangeThreshold = currentAltitude * 0.1 // 10% 변화

        // 첫 로드이거나 altitude가 충분히 변했을 때만
        if lastAltitude == 0 || altitudeDifference >= altitudeChangeThreshold {
            lastAltitude = currentAltitude
            regionDidChangeSubject.send(())
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }

        // Handle custom cluster annotation
        if let cluster = annotation as? CustomClusterAnnotation {
            let identifier = "CustomClusterAnnotation"
            var clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if clusterView == nil {
                clusterView = MKAnnotationView(annotation: cluster, reuseIdentifier: identifier)
                clusterView?.canShowCallout = true
            } else {
                clusterView?.annotation = cluster
            }

            annotationViewBuilder.configureClusterView(clusterView, cluster: cluster)
            return clusterView
        }

        // Handle individual mountain annotation
        let identifier = "MountainAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }

        if let mountainAnnotation = annotation as? MountainAnnotation,
           let mountainDistance = mountainAnnotation.mountainDistance {
            annotationViewBuilder.configureMountainView(annotationView, mountainDistance: mountainDistance)
        }

        return annotationView
    }

    private func setupMapBoundary() {
        let southKoreaRegion = MKCoordinateRegion(
            center: MapConfig.southKoreaCenter,
            latitudinalMeters: MapConfig.regionLatitudinalMeters,
            longitudinalMeters: MapConfig.regionLongitudinalMeters
        )

        let zoomRange = MKMapView.CameraZoomRange(
            minCenterCoordinateDistance: MapConfig.minZoomDistance,
            maxCenterCoordinateDistance: MapConfig.maxZoomDistance
        )

        if let zoomRange {
            mainView.setupMapBoundary(region: southKoreaRegion, zoomRange: zoomRange)
        }
    }

}

// MARK: - UISearchBarDelegate
extension MapViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        mainView.setSearchBarBorder(isFirstResponder: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        mainView.setSearchBarBorder(isFirstResponder: false)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
