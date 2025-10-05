//
//  MapSceneDIContainer.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit
import Domain
import Data

public final class MapSceneDIContainer {

    public init() { }

    public func makeMapSceneFlowCoordinator(navigationController: UINavigationController) -> MapSceneFlowCoordinator {
        return MapSceneFlowCoordinator(navigationController: navigationController, dependencies: self)
    }
}

extension MapSceneDIContainer: MapSceneFlowCoordinatorDependencies {

    // MARK: - ViewControllers
    func makeMapViewController() -> MapViewController {
        return MapViewController(viewModel: makeMapViewModel())
    }

    // MARK: - ViewModels
    private func makeMapViewModel() -> MapViewModel {
        return MapViewModel(fetchMountainLocationUseCase: makeFetchMountainLocationUseCase())
    }

    // MARK: - UseCases
    private func makeFetchMountainLocationUseCase() -> FetchMountainLocationUseCase {
        return FetchMountainLocationUseCaseImpl(repository: makeMountainLocationRepository())
    }

    // MARK: - Repositories
    private func makeMountainLocationRepository() -> MountainLocationRepository {
        return JSONMountainLocationRepositoryImpl()
    }
}
