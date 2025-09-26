//
//  SearchSceneDIContainer.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit

public final class SearchSceneDIContainer {
    
    public init() {}
    
    public func makeSearchSceneFlowCoordinator(navigationController: UINavigationController) -> SearchSceneFlowCoordinator {
        return SearchSceneFlowCoordinator(navigationController: navigationController)
    }
}
