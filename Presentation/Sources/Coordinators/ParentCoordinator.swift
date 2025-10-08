//
//  ParentCoordinator.swift
//  Presentation
//
//  Created by 김영훈 on 10/7/25.
//

import Foundation
import Domain

public protocol ParentCoordinator: AnyObject {
    func showClimbRecordDetail(climbRecord: ClimbRecord)
}
