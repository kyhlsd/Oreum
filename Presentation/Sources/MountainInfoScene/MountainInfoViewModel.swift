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
    private var cancellables = Set<AnyCancellable>()

    init(fetchCoordinateUseCase: FetchCoordinateUseCase, mountainInfo: MountainInfo) {
        self.fetchCoordinateUseCase = fetchCoordinateUseCase
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
        let errorMessage: AnyPublisher<String, Never>
    }

    func transform(input: Input) -> Output {
        let mountainNameSubject = PassthroughSubject<String, Never>()
        let addressSubject = PassthroughSubject<String, Never>()
        let heightSubject = PassthroughSubject<String, Never>()
        let introductionSubject = PassthroughSubject<String, Never>()
        let imageURLSubject = PassthroughSubject<URL?, Never>()
        let errorMessageSubject = PassthroughSubject<String, Never>()

        let fetchCoordinateTrigger = PassthroughSubject<String, Never>()
        
        fetchCoordinateTrigger
            .flatMap { [weak self] address -> AnyPublisher<Result<Coordinate, Error>, Never> in
                guard let self else {
                    return Just(.failure(NSError(domain: "SelfDeallocated", code: -1)))
                        .eraseToAnyPublisher()
                }
                if address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    return Just(.failure(NSError(domain: "Geocoding", code: -2, userInfo: [NSLocalizedDescriptionKey: "주소 변환에 실패했습니다."]))).eraseToAnyPublisher()
                }
                return fetchCoordinateUseCase.execute(address: address)
            }
            .sink { result in
                switch result {
                case .success(let coordinate):
                    print(coordinate)
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
            errorMessage: errorMessageSubject.eraseToAnyPublisher()
        )
    }
    
    private func firstSentence(from text: String) -> String {
        let pattern = "^[가-힣\\s]+"
        
        if let match = text.range(of: pattern, options: .regularExpression) {
            return String(text[match]).trimmingCharacters(in: .whitespaces)
        }
        
        return ""
    }
}
