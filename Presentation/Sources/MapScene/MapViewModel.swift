//
//  MapViewModel.swift
//  Presentation
//
//  Created by 김영훈 on 10/4/25.
//

import Foundation
import Combine
import CoreLocation
import Domain

final class MapViewModel: NSObject, BaseViewModel {

    private let fetchMountainLocationUseCase: FetchMountainLocationUseCase
    private let fetchMountainInfoUseCase: FetchMountainInfoUseCase
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()

    // 서울 시청 좌표
    private let seoulCityHall = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)
    private let userLocationSubject = PassthroughSubject<CLLocationCoordinate2D, Never>()
    
    init(fetchMountainLocationUseCase: FetchMountainLocationUseCase, fetchMountainInfoUseCase: FetchMountainInfoUseCase) {
        self.fetchMountainLocationUseCase = fetchMountainLocationUseCase
        self.fetchMountainInfoUseCase = fetchMountainInfoUseCase
        super.init()
        setupLocationManager()
    }

    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let locationButtonTapped: AnyPublisher<Void, Never>
        let mountainCellTapped: AnyPublisher<MountainDistance, Never>
        let searchText: AnyPublisher<String, Never>
        let mountainInfoButtonTapped: AnyPublisher<(String, Int), Never>
    }

    struct Output {
        let userLocation: AnyPublisher<CLLocationCoordinate2D, Never>
        let displayMountains: AnyPublisher<[MountainDistance], Never>
        let allMountains: AnyPublisher<[MountainDistance], Never>
        let errorMessage: AnyPublisher<String, Never>
        let showLocationPermissionAlert: AnyPublisher<Void, Never>
        let moveToMountainLocation: AnyPublisher<CLLocationCoordinate2D, Never>
        let pushMountainInfo: AnyPublisher<MountainInfo, Never>
    }

    func transform(input: Input) -> Output {

        let nearbyMountainsSubject = PassthroughSubject<[MountainDistance], Never>()
        let allMountainsSubject = PassthroughSubject<[MountainDistance], Never>()
        let errorMessageSubject = PassthroughSubject<String, Never>()
        let showLocationPermissionAlertSubject = PassthroughSubject<Void, Never>()
        let pushMountainInfoSubject = PassthroughSubject<MountainInfo, Never>()

        input.viewDidLoad
            .sink { [weak self] in
                guard let self else { return }
                DispatchQueue.global().async {
                    if CLLocationManager.locationServicesEnabled() {
                        DispatchQueue.main.async {
                            self.requestLocation()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.userLocationSubject.send(self.seoulCityHall)
                        }
                    }
                }
            }
            .store(in: &cancellables)
        
        input.locationButtonTapped
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] in
                guard let self else { return }
                let status = self.locationManager.authorizationStatus

                if status == .denied || status == .restricted {
                    showLocationPermissionAlertSubject.send(())
                } else {
                    self.requestLocation()
                }
            }
            .store(in: &cancellables)
        
        input.mountainInfoButtonTapped
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .flatMap { [weak self] (name, height) in
                let errorInfo = Just(MountainInfo(id: "error", name: "error", address: "error", height: 0, admin: "error", adminNumber: "error", detail: "error", image: nil, referenceDate: Date(), designationCriteria: nil))
                guard let self else { return errorInfo.eraseToAnyPublisher() }
                
                return self.fetchMountainInfoUseCase.execute(name: name, height: height)
                    .catch { error in
                        errorMessageSubject.send(error.localizedDescription)
                        return errorInfo
                    }
                    .eraseToAnyPublisher()
            }
            .sink { mountainInfo in
                pushMountainInfoSubject.send(mountainInfo)
            }
            .store(in: &cancellables)

        userLocationSubject
            .flatMap { [weak self] coordinate -> AnyPublisher<[MountainDistance], Never> in
                guard let self else { return Just([]).eraseToAnyPublisher() }

                return self.fetchMountainLocationUseCase.execute()
                    .map { mountainLocations in
                        mountainLocations
                            .map { mountainLocation in
                                let distance = self.calculateDistance(from: coordinate, to: mountainLocation)
                                return MountainDistance(mountainLocation: mountainLocation, distance: distance)
                            }
                            .sorted { $0.distance < $1.distance }
                    }
                    .catch { error -> Just<[MountainDistance]> in
                        errorMessageSubject.send(error.localizedDescription)
                        return Just([])
                    }
                    .eraseToAnyPublisher()
            }
            .sink { mountains in
                allMountainsSubject.send(mountains)
                nearbyMountainsSubject.send(Array(mountains.prefix(20)))
            }
            .store(in: &cancellables)

        let moveToMountainLocation = input.mountainCellTapped
            .map {
                CLLocationCoordinate2D(
                    latitude: $0.mountainLocation.latitude,
                    longitude: $0.mountainLocation.longitude
                )
            }
            .eraseToAnyPublisher()

        let displayMountains = Publishers.CombineLatest(
            allMountainsSubject,
            input.searchText
                .debounce(for: .seconds(0.3), scheduler: RunLoop.main)
                .prepend("")
        )
        .map { allMountains, searchText -> [MountainDistance] in
            let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !trimmedSearchText.isEmpty else {
                return Array(allMountains.prefix(20))
            }

            return allMountains.filter { mountain in
                mountain.mountainLocation.name.localizedCaseInsensitiveContains(trimmedSearchText) ||
                mountain.mountainLocation.address.localizedCaseInsensitiveContains(trimmedSearchText)
            }
        }
        .eraseToAnyPublisher()

        return Output(
            userLocation: userLocationSubject.eraseToAnyPublisher(),
            displayMountains: displayMountains,
            allMountains: allMountainsSubject.eraseToAnyPublisher(),
            errorMessage: errorMessageSubject.eraseToAnyPublisher(),
            showLocationPermissionAlert: showLocationPermissionAlertSubject.eraseToAnyPublisher(),
            moveToMountainLocation: moveToMountainLocation,
            pushMountainInfo: pushMountainInfoSubject.eraseToAnyPublisher()
        )
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    private func requestLocation() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            userLocationSubject.send(seoulCityHall)
        @unknown default:
            userLocationSubject.send(seoulCityHall)
        }
    }

    private func calculateDistance(from userLocation: CLLocationCoordinate2D, to mountainLocation: MountainLocation) -> Double {
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let mountainCLLocation = CLLocation(latitude: mountainLocation.latitude, longitude: mountainLocation.longitude)
        return userCLLocation.distance(from: mountainCLLocation) / 1000 // km 단위
    }
}

// MARK: - CLLocationManagerDelegate
extension MapViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationManager.stopUpdatingLocation()
        userLocationSubject.send(location.coordinate)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
        userLocationSubject.send(seoulCityHall)
    }
}
