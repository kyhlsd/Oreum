//
//  MountainInfoViewModel.swift
//  Presentation
//
//  Created by 김영훈 on 10/5/25.
//

import Foundation
import Combine
import Domain

final class MountainInfoViewModel: BaseViewModel {

    private let mountainInfo: MountainInfo
    private let fetchCoordinateUseCase: FetchCoordinateUseCase
    private let fetchWeeklyForecastUseCase: FetchWeeklyForecastUseCase
    private let fetchMountainImageUseCase: FetchMountainImageUseCase
    private var cancellables = Set<AnyCancellable>()

    private(set) var imageURLStrings: [String] = []

    init(
        fetchCoordinateUseCase: FetchCoordinateUseCase,
        fetchWeeklyForecastUseCase: FetchWeeklyForecastUseCase,
        fetchMountainImageUseCase: FetchMountainImageUseCase,
        mountainInfo: MountainInfo
    ) {
        self.fetchCoordinateUseCase = fetchCoordinateUseCase
        self.fetchWeeklyForecastUseCase = fetchWeeklyForecastUseCase
        self.fetchMountainImageUseCase = fetchMountainImageUseCase
        self.mountainInfo = mountainInfo
    }

    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let viewDidAppear: AnyPublisher<Void, Never>
    }

    struct Output {
        let mountainInfo: AnyPublisher<MountainInfo, Never>
        let imageURLs: AnyPublisher<[String], Never>
        let weeklyForecast: AnyPublisher<[DailyForecast], Never>
        let errorMessage: AnyPublisher<(String, String), Never>
    }

    func transform(input: Input) -> Output {
        let mountainInfoSubject = PassthroughSubject<MountainInfo, Never>()
        let imageURLsSubject = PassthroughSubject<[String], Never>()
        let weeklyForecastSubject = PassthroughSubject<[DailyForecast], Never>()
        let errorMessageSubject = PassthroughSubject<(String, String), Never>()

        let fetchCoordinateTrigger = PassthroughSubject<String, Never>()
        let fetchWeeklyForecastTrigger = PassthroughSubject<Coordinate, Never>()
        let viewDidAppear = input.viewDidAppear
            .prefix(1)
            .share()
        
        // Geocoding
        fetchCoordinateTrigger
            .flatMap { [weak self] address -> AnyPublisher<Result<Coordinate, Error>, Never> in
                guard let self else {
                    return Just(.failure(NSError(domain: "SelfDeallocated", code: -1)))
                        .eraseToAnyPublisher()
                }
                return fetchCoordinateUseCase.execute(address: address)
            }
            .sink { result in
                switch result {
                case .success(let coordinate):
                    fetchWeeklyForecastTrigger.send(coordinate)
                case .failure(let error):
                    errorMessageSubject.send(("주소 변환 실패", error.localizedDescription))
                }
            }
            .store(in: &cancellables)
        
        // 날씨 예보
        fetchWeeklyForecastTrigger
            .flatMap { [weak self] coordinate -> AnyPublisher<Result<[DailyForecast], Error>, Never> in
                guard let self else {
                    return Empty().eraseToAnyPublisher()
                }
                return fetchWeeklyForecastUseCase.execute(longitude: coordinate.longitude, latitude: coordinate.latitude)
            }
            .sink { result in
                switch result {
                case .success(let value):
                    weeklyForecastSubject.send(value)
                case .failure(let error):
                    errorMessageSubject.send(("날씨 예보 가져오기 실패", error.localizedDescription))
                }
            }
            .store(in: &cancellables)

        // 기본 정보 표시
        input.viewDidLoad
            .sink { [weak self] in
                guard let self else { return }
                mountainInfoSubject.send(mountainInfo)
            }
            .store(in: &cancellables)

        // API 호출
        viewDidAppear
            .flatMap { [weak self] _ -> AnyPublisher<Result<[String], Error>, Never> in
                guard let self else {
                    return Empty().eraseToAnyPublisher()
                }
                return self.fetchMountainImageUseCase.execute(id: self.mountainInfo.id)
            }
            .sink { [weak self] result in
                switch result {
                case .success(let urlStrings):
                    self?.imageURLStrings = urlStrings
                    imageURLsSubject.send(urlStrings)
                case .failure(let error):
                    self?.imageURLStrings = []
                    errorMessageSubject.send(("이미지 가져오기 실패", error.localizedDescription))
                    imageURLsSubject.send([])
                }
            }
            .store(in: &cancellables)

        viewDidAppear
            .sink { [weak self] in
                guard let self else { return }
                fetchCoordinateTrigger.send(firstSentence(from: mountainInfo.address))
            }
            .store(in: &cancellables)

        return Output(
            mountainInfo: mountainInfoSubject.eraseToAnyPublisher(),
            imageURLs: imageURLsSubject.eraseToAnyPublisher(),
            weeklyForecast: weeklyForecastSubject.eraseToAnyPublisher(),
            errorMessage: errorMessageSubject.eraseToAnyPublisher()
        )
    }
    
    // MARK: - Private Methods
    
    // 산 주소에서 시/군 단위 행정 구역까지만 가져오기
    private func firstSentence(from text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = trimmed.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
        return parts.prefix(2).joined(separator: " ")
    }
}
