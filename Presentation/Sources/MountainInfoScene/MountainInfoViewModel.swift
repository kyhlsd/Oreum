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
    private var cancellables = Set<AnyCancellable>()

    init(mountainInfo: MountainInfo) {
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
    }

    func transform(input: Input) -> Output {
        let mountainNameSubject = PassthroughSubject<String, Never>()
        let addressSubject = PassthroughSubject<String, Never>()
        let heightSubject = PassthroughSubject<String, Never>()
        let introductionSubject = PassthroughSubject<String, Never>()
        let imageURLSubject = PassthroughSubject<URL?, Never>()

        input.viewDidLoad
            .sink { [weak self] in
                guard let self else { return }

                mountainNameSubject.send(self.mountainInfo.name)
                addressSubject.send(self.mountainInfo.address)
                heightSubject.send("\(self.mountainInfo.height)m")
                introductionSubject.send(self.mountainInfo.detail)
                imageURLSubject.send(self.mountainInfo.image.flatMap { URL(string: $0) })
            }
            .store(in: &cancellables)

        return Output(
            mountainName: mountainNameSubject.eraseToAnyPublisher(),
            address: addressSubject.eraseToAnyPublisher(),
            height: heightSubject.eraseToAnyPublisher(),
            introduction: introductionSubject.eraseToAnyPublisher(),
            imageURL: imageURLSubject.eraseToAnyPublisher()
        )
    }
}
