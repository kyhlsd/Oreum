//
//  Coordinator.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit

public protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    func start()
}
