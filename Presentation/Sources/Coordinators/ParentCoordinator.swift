//
//  ParentCoordinator.swift
//  Presentation
//
//  Created by 김영훈 on 10/7/25.
//

import Foundation
import Domain

// 다른 탭으로 전환에 사용
public protocol ParentCoordinator: AnyObject {
    func showClimbRecordDetail(climbRecord: ClimbRecord)
}
