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
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()

    // 서울 시청 좌표
    private let seoulCityHall = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)
    private let userLocationSubject = PassthroughSubject<CLLocationCoordinate2D, Never>()
    
    init(fetchMountainLocationUseCase: FetchMountainLocationUseCase) {
        self.fetchMountainLocationUseCase = fetchMountainLocationUseCase
        super.init()
        setupLocationManager()
    }

    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
    }

    struct Output {
        let userLocation: AnyPublisher<CLLocationCoordinate2D, Never>
        let nearbyMountains: AnyPublisher<[MountainDistance], Never>
        let errorMessage: AnyPublisher<String, Never>
    }

    func transform(input: Input) -> Output {
        
        let nearbyMountainsSubject = PassthroughSubject<[MountainDistance], Never>()
        let errorMessageSubject = PassthroughSubject<String, Never>()

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

        // 위치를 받아서 근처 명산 로딩
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
                            .prefix(10)
                            .map { $0 }
                    }
                    .catch { error -> Just<[MountainDistance]> in
                        errorMessageSubject.send(error.localizedDescription)
                        return Just([])
                    }
                    .eraseToAnyPublisher()
            }
            .sink { mountains in
                nearbyMountainsSubject.send(mountains)
            }
            .store(in: &cancellables)

        return Output(
            userLocation: userLocationSubject.eraseToAnyPublisher(),
            nearbyMountains: nearbyMountainsSubject.eraseToAnyPublisher(),
            errorMessage: errorMessageSubject.eraseToAnyPublisher()
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
