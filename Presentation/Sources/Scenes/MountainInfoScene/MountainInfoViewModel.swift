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
    private var cancellables = Set<AnyCancellable>()

    init(fetchCoordinateUseCase: FetchCoordinateUseCase, fetchWeeklyForecastUseCase: FetchWeeklyForecastUseCase, mountainInfo: MountainInfo) {
        self.fetchCoordinateUseCase = fetchCoordinateUseCase
        self.fetchWeeklyForecastUseCase = fetchWeeklyForecastUseCase
        self.mountainInfo = mountainInfo
    }

    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
    }

    struct Output {
        let mountainName: AnyPublisher<String, Never>
        let address: AnyPublisher<String, Never>
        let height: AnyPublisher<String, Never>
        let introduction: AnyPublisher<String, Never>
        let imageURL: AnyPublisher<URL?, Never>
        let weeklyForecast: AnyPublisher<[DailyForecast], Never>
        let errorMessage: AnyPublisher<String, Never>
    }

    func transform(input: Input) -> Output {
        let mountainNameSubject = PassthroughSubject<String, Never>()
        let addressSubject = PassthroughSubject<String, Never>()
        let heightSubject = PassthroughSubject<String, Never>()
        let introductionSubject = PassthroughSubject<String, Never>()
        let imageURLSubject = PassthroughSubject<URL?, Never>()
        let weeklyForecastSubject = PassthroughSubject<[DailyForecast], Never>()
        let errorMessageSubject = PassthroughSubject<String, Never>()

        let fetchCoordinateTrigger = PassthroughSubject<String, Never>()
        let fetchWeeklyForecastTrigger = PassthroughSubject<Coordinate, Never>()
        
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
                    errorMessageSubject.send(error.localizedDescription)
                }
            }
            .store(in: &cancellables)
        
        // 날씨 예보
        fetchWeeklyForecastTrigger
            .flatMap { [weak self] coordinate -> AnyPublisher<Result<[DailyForecast], Error>, Never> in
                guard let self else {
                    return Just(.failure(NSError(domain: "SelfDeallocated", code: -1)))
                        .eraseToAnyPublisher()
                }
                return fetchWeeklyForecastUseCase.execute(longitude: coordinate.longitude, latitude: coordinate.latitude)
            }
            .sink { result in
                switch result {
                case .success(let value):
                    weeklyForecastSubject.send(value)
                case .failure(let error):
                    errorMessageSubject.send(error.localizedDescription)
                }
            }
            .store(in: &cancellables)
        
        input.viewDidLoad
            .sink { [weak self] in
                guard let self else { return }

                mountainNameSubject.send(mountainInfo.name)
                addressSubject.send(mountainInfo.address)
                heightSubject.send("\(mountainInfo.height)m")
                introductionSubject.send(mountainInfo.detail)
                imageURLSubject.send(mountainInfo.image.flatMap { URL(string: $0) })
                fetchCoordinateTrigger.send(firstSentence(from: mountainInfo.address))
            }
            .store(in: &cancellables)

        return Output(
            mountainName: mountainNameSubject.eraseToAnyPublisher(),
            address: addressSubject.eraseToAnyPublisher(),
            height: heightSubject.eraseToAnyPublisher(),
            introduction: introductionSubject.eraseToAnyPublisher(),
            imageURL: imageURLSubject.eraseToAnyPublisher(),
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
