//
//  MeasureSceneDIContainer.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit

public final class MeasureSceneDIContainer {
    
    public init() {}
    
    public func makeMeasureSceneFlowCoordinator(navigationController: UINavigationController) -> MeasureSceneFlowCoordinator {
        return MeasureSceneFlowCoordinator(navigationController: navigationController, dependencies: self)
    }
}

extension MeasureSceneDIContainer: MeasureSceneFlowCoordinatorDependencies {
    
    // MARK: - ViewControllers
    func makeMeasureViewController() -> MeasureViewController {
        return MeasureViewController(viewModel: makeMeasureViewModel())
    }
    
    // MARK: - ViewModels
    private func makeMeasureViewModel() -> MeasureViewModel {
        return MeasureViewModel()
    }
}
