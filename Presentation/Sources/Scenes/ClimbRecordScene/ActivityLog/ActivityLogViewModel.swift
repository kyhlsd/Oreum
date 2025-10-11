//
//  ActivityLogViewModel.swift
//  Presentation
//
//  Created by 김영훈 on 9/30/25.
//

import Foundation
import Domain
import Combine

final class ActivityLogViewModel {
    
    private let activityStatUseCase: ActivityStatUseCase
    private var cancellables = Set<AnyCancellable>()
    
    private(set) var climbRecord: ClimbRecord
    
    init(activityStatUseCase: ActivityStatUseCase, climbRecord: ClimbRecord) {
        self.activityStatUseCase = activityStatUseCase
        self.climbRecord = climbRecord
    }
    
    struct Input { }
    
    struct Output {
        let mountainName: String
        let activityStat: ActivityStat
        let activityLogs: [ActivityLog]
    }
    
    func transform(input: Input) -> Output {
        let stat = activityStatUseCase.execute(activityLogs: climbRecord.timeLog)
        
        return Output(
            mountainName: climbRecord.mountain.name,
            activityStat: stat,
            activityLogs: climbRecord.timeLog
        )
    }
}
