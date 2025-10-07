//
//  AppFlowCoordinator.swift
//  Oreum
//
//  Created by 김영훈 on 9/25/25.
//

import UIKit
import Presentation
import Domain

final class AppFlowCoordinator: ParentCoordinator {

    private let window: UIWindow
    private let tabBarController: UITabBarController
    private let appDIContainer: AppDIContainer
    private var childCoordinators = [Coordinator]()
    private var recordFlow: RecordSceneFlowCoordinator?

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
        
        recordFlow = recordDIContainer.makeRecordSceneFlowCoordinator(navigationController: recordNav)
        let measureFlow = measureDIContainer.makeMeasureSceneFlowCoordinator(navigationController: measureNav)
        let mapFlow = mapDIContainer.makeMapSceneFlowCoordinator(navigationController: mapNav)
        let searchFlow = searchDIContainer.makeSearchSceneFlowCoordinator(navigationController: searchNav)

        // parent coordinator 설정
        measureFlow.parentCoordinator = self

        if let recordFlow = recordFlow {
            childCoordinators.append(recordFlow)
        }
        childCoordinators.append(measureFlow)
        childCoordinators.append(mapFlow)
        childCoordinators.append(searchFlow)
        
        recordFlow?.start()
        measureFlow.start()
        mapFlow.start()
        searchFlow.start()
        
        tabBarController.viewControllers = [recordNav, measureNav, mapNav, searchNav]
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    func showClimbRecordDetail(climbRecord: ClimbRecord) {
        // 기록 탭(index 0)으로 전환
        tabBarController.selectedIndex = 0

        // RecordSceneFlowCoordinator를 통해 DetailVC 표시
        recordFlow?.showDetailFromMeasure(climbRecord: climbRecord)
    }
}
