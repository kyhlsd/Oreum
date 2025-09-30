//
//  AppFlowCoordinator.swift
//  Oreum
//
//  Created by 김영훈 on 9/25/25.
//

import UIKit
import Presentation

final class AppFlowCoordinator {
    
    private let window: UIWindow
    private let tabBarController: UITabBarController
    private let appDIContainer: AppDIContainer
    private var childCoordinators = [Coordinator]()
    
    init(window: UIWindow, tabBarController: UITabBarController, appDIContainer: AppDIContainer) {
        self.window = window
        self.tabBarController = tabBarController
        self.appDIContainer = appDIContainer
    }
    
    func start() {
        let recordDIContainer = appDIContainer.makeRecordSceneDIContainer()
        let measureDIContainer = appDIContainer.makeMeasureSceneDIContainer()
        let mapDIContainer = appDIContainer.makeMapSceneDIContainer()
        let searchDIContainer = appDIContainer.makeSearchSceneDIContainer()
        
        let recordNav = UINavigationController()
        let measureNav = UINavigationController()
        let mapNav = UINavigationController()
        let searchNav = UINavigationController()
        
        let recordFlow = recordDIContainer.makeRecordSceneFlowCoordinator(navigationController: recordNav)
        let measureFlow = measureDIContainer.makeMeasureSceneFlowCoordinator(navigationController: measureNav)
        let mapFlow = mapDIContainer.makeMapSceneFlowCoordinator(navigationController: mapNav)
        let searchFlow = searchDIContainer.makeSearchSceneFlowCoordinator(navigationController: searchNav)
        
        childCoordinators.append(recordFlow)
        childCoordinators.append(measureFlow)
        childCoordinators.append(mapFlow)
        childCoordinators.append(searchFlow)
        
        recordFlow.start()
        measureFlow.start()
        mapFlow.start()
        searchFlow.start()
        
        tabBarController.viewControllers = [recordNav, measureNav, mapNav, searchNav]
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}
