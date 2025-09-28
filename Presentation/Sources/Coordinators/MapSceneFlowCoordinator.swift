//
//  MapSceneFlowCoordinator.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit

public final class MapSceneFlowCoordinator: Coordinator {
    
    public let navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        navigationController.tabBarItem = UITabBarItem(title: "지도", image: AppIcon.map, tag: 2)
        let vc = UIViewController()
        vc.view.backgroundColor = .white
        navigationController.pushViewController(vc, animated: false)
    }
}
