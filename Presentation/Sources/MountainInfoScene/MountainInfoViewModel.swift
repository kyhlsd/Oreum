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
        let mountainInfo: AnyPublisher<MountainInfo, Never>
    }

    func transform(input: Input) -> Output {
        let mountainInfoSubject = PassthroughSubject<MountainInfo, Never>()

        input.viewDidLoad
            .sink { [weak self] in
                guard let self else { return }
                mountainInfoSubject.send(self.mountainInfo)
            }
            .store(in: &cancellables)

        return Output(
            mountainInfo: mountainInfoSubject.eraseToAnyPublisher()
        )
    }
}
