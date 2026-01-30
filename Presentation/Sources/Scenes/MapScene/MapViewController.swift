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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
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

        // 사용자 위치
        output.userLocation
            .sink { [weak self] coordinate in
                self?.mainView.updateMapRegion(coordinate: coordinate)
            }
            .store(in: &cancellables)

        // 명산 리스트
        output.displayMountains
            .sink { [weak self] mountains in
                self?.applySnapshot(mountains: mountains)
                self?.mainView.showEmptyState(mountains.isEmpty)
                self?.mainView.collectionView.setContentOffset(.zero, animated: false)
            }
            .store(in: &cancellables)

        // 지도에 표기할 명산
        output.allMountains
            .sink { [weak self] mountains in
                self?.annotationManager.updateMountains(mountains)
                self?.updateClusteredAnnotations()
            }
            .store(in: &cancellables)

        // 위치 권한 Alert
        output.showLocationPermissionAlert
            .sink { [weak self] in
                self?.presentCancellableAlert(title: "위치 권한 필요", message: "위치 권한이 거부되어 있습니다.\n설정으로 이동하시겠습니까?") {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }
            }
            .store(in: &cancellables)

        // 산 선택 시
        output.moveToMountainLocation
            .sink { [weak self] coordinate in
                self?.mainView.updateMapRegion(coordinate: coordinate)
            }
            .store(in: &cancellables)
        
        // 상세 정보 보기
        output.pushMountainInfo
            .sink { [weak self] mountainInfo in
                self?.pushInfoVC?(mountainInfo)
            }
            .store(in: &cancellables)
        
        // 에러 Alert
        output.errorMessage
            .sink { [weak self] (title, message) in
                self?.presentDefaultAlert(title: title, message: message)
            }
            .store(in: &cancellables)

        // 지도 영역 변경
        regionDidChangeSubject
            .debounce(for: .seconds(0.3), scheduler: RunLoop.main)
            .sink { [weak self] in
                self?.updateClusteredAnnotations()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Setups
    private func setupNavItem() {
        if #unavailable(iOS 26.0) {
            navigationItem.backButtonTitle = " "
        }
    }

    private func setupAnnotationViewBuilder() {
        // 상세 정보 보기 선택 시
        annotationViewBuilder.mountainInfoButtonTapped
            .sink { [weak self] name, id in
                self?.mountainInfoButtonTappedSubject.send((name, id))
            }
            .store(in: &cancellables)

        // 클러스터링 테이블 뷰에서 산 선택 시
        annotationViewBuilder.clusterMountainSelected
            .sink { [weak self] mountain in
                guard let self else { return }
                
                let coordinate = CLLocationCoordinate2D(
                    latitude: mountain.mountainLocation.latitude,
                    longitude: mountain.mountainLocation.longitude
                )

                // 클러스터 callout 닫기
                mainView.mapView.deselectAnnotation(mainView.mapView.selectedAnnotations.first, animated: false)

                // 선택된 산으로 줌
                mainView.updateMapRegion(coordinate: coordinate)
            }
            .store(in: &cancellables)
    }
    
    private func setupDelegates() {
        mainView.collectionView.delegate = self
        mainView.mapView.delegate = self
        mainView.searchBar.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

}

// MARK: - UICollectionViewDelegate + SubMethods
extension MapViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let mountain = dataSource.itemIdentifier(for: indexPath) else { return }
        mountainCellTappedSubject.send(mountain)
    }
    
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
        snapshot.appendItems(mountains.uniq(by: \.self))
        dataSource.apply(snapshot, animatingDifferences: true)
    }

}

// MARK: - MKMapViewDelegate + SubMethods
extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        regionDidChangeSubject.send(())
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }

        // 클러스터 어노테이션일 때
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

        // 개별 산 어노테이션일 때
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

    // 클러스터 어노테이션 업데이트
    private func updateClusteredAnnotations() {
        let (toAdd, toRemove) = annotationManager.updateAnnotations(on: mainView.mapView)

        // 변경사항이 있을 때만 업데이트
        if !toRemove.isEmpty || !toAdd.isEmpty {
            mainView.mapView.removeAnnotations(toRemove)
            mainView.mapView.addAnnotations(toAdd)
        }
    }
    
    // 지도 범위 한국 한정
    private func setupMapBoundary() {
        let southKoreaCenter = CLLocationCoordinate2D(latitude: 36.5, longitude: 127.5)
        let regionLatitudinalMeters: CLLocationDistance = 800000
        let regionLongitudinalMeters: CLLocationDistance = 600000
        let minZoomDistance: CLLocationDistance = 5000
        let maxZoomDistance: CLLocationDistance = 2000000
        
        let southKoreaRegion = MKCoordinateRegion(
            center: southKoreaCenter,
            latitudinalMeters: regionLatitudinalMeters,
            longitudinalMeters: regionLongitudinalMeters
        )
        
        let zoomRange = MKMapView.CameraZoomRange(
            minCenterCoordinateDistance: minZoomDistance,
            maxCenterCoordinateDistance: maxZoomDistance
        )
        
        if let zoomRange {
            mainView.setupMapBoundary(region: southKoreaRegion, zoomRange: zoomRange)
        }
    }

}

// MARK: - UISearchBarDelegate
extension MapViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        mainView.setWithFirstResponder(isFirstResponder: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        mainView.setWithFirstResponder(isFirstResponder: false)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
