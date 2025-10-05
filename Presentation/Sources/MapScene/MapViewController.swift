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
        bind()

        viewDidLoadSubject.send(())
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
            }
            .store(in: &cancellables)

        output.allMountains
            .sink { [weak self] mountains in
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
    }
    
    private func setupNavItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: NavTitleLabel(title: "내 주위 명산"))
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

    private func updateMapAnnotations(mountains: [MountainDistance]) {
        mainView.mapView.removeAnnotations(mainView.mapView.annotations)

        let annotations = mountains.map { mountain -> MountainAnnotation in
            let annotation = MountainAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(
                latitude: mountain.mountainLocation.latitude,
                longitude: mountain.mountainLocation.longitude
            )
            annotation.mountainDistance = mountain
            return annotation
        }

        mainView.mapView.addAnnotations(annotations)
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }

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
            configureAnnotationView(annotationView, with: mountainDistance.mountainLocation.name)
            configureCalloutView(for: annotationView, with: mountainDistance)
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

    private func configureCalloutView(for annotationView: MKAnnotationView?, with mountainDistance: MountainDistance) {
        let calloutView = MountainAnnotationCalloutView()
        calloutView.configure(with: mountainDistance)
        calloutView.infoButton.tap
            .sink { [weak self] in
                self?.mountainInfoButtonTappedSubject.send((mountainDistance.mountainLocation.name, mountainDistance.mountainLocation.height))
            }
            .store(in: &cancellables)
        annotationView?.detailCalloutAccessoryView = calloutView
    }

    private func configureAnnotationView(_ annotationView: MKAnnotationView?, with title: String) {
        guard let combinedImage = createAnnotationImage(with: title) else { return }

        let imageSize = CGSize(width: 40, height: 60)
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: AppColor.primaryText
        ]
        let textSize = (title as NSString).size(withAttributes: textAttributes)
        let padding: CGFloat = 8
        let backgroundHeight = textSize.height + padding
        let totalHeight = imageSize.height + backgroundHeight + 4

        annotationView?.image = combinedImage
        annotationView?.centerOffset = CGPoint(x: 0, y: -totalHeight / 2)
    }

    private func createAnnotationImage(with title: String) -> UIImage? {
        guard let originalImage = UIImage(named: "MapPin", in: .module, with: nil) else { return nil }

        let imageSize = CGSize(width: 40, height: 60)
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: AppColor.primaryText
        ]
        let textSize = (title as NSString).size(withAttributes: textAttributes)
        let padding: CGFloat = 8
        let backgroundWidth = textSize.width + padding * 2
        let backgroundHeight = textSize.height + padding
        let totalWidth = max(imageSize.width, backgroundWidth)
        let totalHeight = imageSize.height + backgroundHeight + 4

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: totalWidth, height: totalHeight))
        return renderer.image { context in
            let imageX = (totalWidth - imageSize.width) / 2
            originalImage.draw(in: CGRect(x: imageX, y: 0, width: imageSize.width, height: imageSize.height))

            let backgroundX = (totalWidth - backgroundWidth) / 2
            let backgroundY = imageSize.height - 8
            let backgroundRect = CGRect(x: backgroundX, y: backgroundY, width: backgroundWidth, height: backgroundHeight)
            let path = UIBezierPath(roundedRect: backgroundRect, cornerRadius: 8)
            UIColor.white.setFill()
            path.fill()

            let textX = backgroundX + padding
            let textY = backgroundY + padding / 2
            (title as NSString).draw(at: CGPoint(x: textX, y: textY), withAttributes: textAttributes)
        }
    }
}

// MARK: - MountainAnnotation
final class MountainAnnotation: MKPointAnnotation {
    var mountainDistance: MountainDistance?
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
