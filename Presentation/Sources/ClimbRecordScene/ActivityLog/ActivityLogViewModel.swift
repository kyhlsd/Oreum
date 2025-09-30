//
//  ActivityLogViewModel.swift
//  Presentation
//
//  Created by 김영훈 on 9/30/25.
//

import Foundation
import Domain

final class ActivityLogViewModel {
    
    private(set) var climbRecord: ClimbRecord
    
    init(climbRecord: ClimbRecord) {
        self.climbRecord = climbRecord
    }
}
