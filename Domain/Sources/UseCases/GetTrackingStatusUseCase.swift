//
//  GetTrackingStatusUseCase.swift
//  Domain
//
//  Created by 김영훈 on 10/2/25.
//

import Foundation
import Combine

public protocol GetTrackingStatusUseCase {
    func execute() -> AnyPublisher<Bool, Never>
}
