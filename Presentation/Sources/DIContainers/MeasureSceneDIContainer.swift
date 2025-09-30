//
//  MeasureSceneDIContainer.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit
import Domain
import Data

public final class MeasureSceneDIContainer {

    public init() {}

    public func makeMeasureSceneFlowCoordinator(navigationController: UINavigationController) -> MeasureSceneFlowCoordinator {
        return MeasureSceneFlowCoordinator(navigationController: navigationController, dependencies: self)
    }

    // MARK: - Repositories
    private func makeTempMountainRepository() -> MountainInfoRepository {
        return DummyMountainInfoRepositoryImpl()
    }

    // MARK: - UseCases
    private func makeFetchMountainsUseCase() -> FetchMountainInfosUseCase {
        return FetchMountainInfosUseCaseImpl(repository: makeTempMountainRepository())
    }
}

extension MeasureSceneDIContainer: MeasureSceneFlowCoordinatorDependencies {

    // MARK: - ViewControllers
    func makeMeasureViewController() -> MeasureViewController {
        return MeasureViewController(viewModel: makeMeasureViewModel())
    }

    // MARK: - ViewModels
    private func makeMeasureViewModel() -> MeasureViewModel {
        return MeasureViewModel(fetchMountainsUseCase: makeFetchMountainsUseCase())
    }
}
