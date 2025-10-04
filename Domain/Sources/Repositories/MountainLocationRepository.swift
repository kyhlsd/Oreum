//
//  MountainLocationRepository.swift
//  Domain
//
//  Created by 김영훈 on 10/4/25.
//

import Foundation
import Combine

public protocol MountainLocationRepository {
    func fetchMountainLocations() -> AnyPublisher<[MountainLocation], Error> 
}
