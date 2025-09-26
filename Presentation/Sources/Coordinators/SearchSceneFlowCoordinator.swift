//
//  SearchSceneFlowCoordinator.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit

public final class SearchSceneFlowCoordinator: Coordinator {
    
    let navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        navigationController.tabBarItem = UITabBarItem(title: "검색", image: AppIcon.search, tag: 3)
        let vc = UIViewController()
        vc.view.backgroundColor = .white
        navigationController.pushViewController(vc, animated: false)
    }
}
