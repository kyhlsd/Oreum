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

    private let seoulCityHall = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)
    
    private let userLocationSubject = PassthroughSubject<CLLocationCoordinate2D, Never>()
    private let errorMessageSubject = PassthroughSubject<(String, String), Never>()
    
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
        let showLocationPermissionAlert: AnyPublisher<Void, Never>
        let moveToMountainLocation: AnyPublisher<CLLocationCoordinate2D, Never>
        let pushMountainInfo: AnyPublisher<MountainInfo, Never>
        let errorMessage: AnyPublisher<(String, String), Never>
    }

    func transform(input: Input) -> Output {
        let allMountainsSubject = PassthroughSubject<[MountainDistance], Never>()
        let showLocationPermissionAlertSubject = PassthroughSubject<Void, Never>()
        let pushMountainInfoSubject = PassthroughSubject<MountainInfo, Never>()

        // 위치 권환 확인
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
        
        // 현재 위치 버튼
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
        
        // 상세 정보 보기 버튼
        input.mountainInfoButtonTapped
            .throttle(for: .seconds(0.3), scheduler: RunLoop.main, latest: true)
            .flatMap { [weak self] (name, height) in
                let errorInfo = Just(MountainInfo(id: "error", name: "error", address: "error", height: 0, admin: "error", adminNumber: "error", detail: "error", image: nil, referenceDate: Date(), designationCriteria: nil))
                guard let self else { return errorInfo.eraseToAnyPublisher() }
                
                return self.fetchMountainInfoUseCase.execute(name: name, height: height)
                    .catch { [weak self] error in
                        self?.errorMessageSubject.send(("산 정보 가져오기 실패", error.localizedDescription))
                        return errorInfo
                    }
                    .eraseToAnyPublisher()
            }
            .sink { mountainInfo in
                pushMountainInfoSubject.send(mountainInfo)
            }
            .store(in: &cancellables)

        // 사용자 위치
        userLocationSubject
            .flatMap { [weak self] coordinate -> AnyPublisher<[MountainDistance], Never> in
                guard let self else { return Just([]).eraseToAnyPublisher() }
                // 산과 거리 계산
                return self.fetchMountainLocationUseCase.execute()
                    .map { mountainLocations in
                        mountainLocations
                            .map { mountainLocation in
                                let distance = self.calculateDistance(from: coordinate, to: mountainLocation)
                                return MountainDistance(mountainLocation: mountainLocation, distance: distance)
                            }
                            .sorted { $0.distance < $1.distance }
                    }
                    .catch { [weak self] error -> Just<[MountainDistance]> in
                        self?.errorMessageSubject.send(("산 위치 가져오기 실패", error.localizedDescription))
                        return Just([])
                    }
                    .eraseToAnyPublisher()
            }
            .sink { mountains in
                allMountainsSubject.send(mountains)
            }
            .store(in: &cancellables)

        // 위치 정보가 바뀌거나, 검색 시 리스트 업데이트
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
        
        // 선택된 산 위경도
        let moveToMountainLocation = input.mountainCellTapped
            .map {
                CLLocationCoordinate2D(
                    latitude: $0.mountainLocation.latitude,
                    longitude: $0.mountainLocation.longitude
                )
            }
            .eraseToAnyPublisher()

        return Output(
            userLocation: userLocationSubject.eraseToAnyPublisher(),
            displayMountains: displayMountains,
            allMountains: allMountainsSubject.eraseToAnyPublisher(),
            showLocationPermissionAlert: showLocationPermissionAlertSubject.eraseToAnyPublisher(),
            moveToMountainLocation: moveToMountainLocation,
            pushMountainInfo: pushMountainInfoSubject.eraseToAnyPublisher(),
            errorMessage: errorMessageSubject.eraseToAnyPublisher()
        )
    }
    
    // MARK: - Private Methods

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
        errorMessageSubject.send(("위치 정보 가져오기 실패", error.localizedDescription))
        userLocationSubject.send(seoulCityHall)
    }
}
