//
//  MapSceneDIContainer.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit
import Domain
import Data
import Core

public final class MapSceneDIContainer {

    private let configuration: EnvironmentConfigurable

    public init(configuration: EnvironmentConfigurable) {
        self.configuration = configuration
    }

    public func makeMapSceneFlowCoordinator(navigationController: UINavigationController) -> MapSceneFlowCoordinator {
        return MapSceneFlowCoordinator(navigationController: navigationController, dependencies: self)
    }
}

extension MapSceneDIContainer: MapSceneFlowCoordinatorDependencies {

    // MARK: - ViewControllers
    func makeMapViewController() -> MapViewController {
        return MapViewController(viewModel: makeMapViewModel())
    }
    
    func makeMountainInfoViewController(mountainInfo: MountainInfo) -> MountainInfoViewController {
        return MountainInfoViewController(viewModel: makeMountainInfoViewModel(mountainInfo: mountainInfo))
    }

    // MARK: - ViewModels
    private func makeMapViewModel() -> MapViewModel {
        return MapViewModel(fetchMountainLocationUseCase: makeFetchMountainLocationUseCase(), fetchMountainInfoUseCase: makeFetchMountainInfoUseCase())
    }
    
    private func makeMountainInfoViewModel(mountainInfo: MountainInfo) -> MountainInfoViewModel {
        return MountainInfoViewModel(fetchCoordinateUseCase: makeFetchCoordinateUseCase(), fetchWeeklyForecastUseCase: makeFetchWeeklyForecastUseCase(), mountainInfo: mountainInfo)
    }

    // MARK: - UseCases
    private func makeFetchMountainLocationUseCase() -> FetchMountainLocationUseCase {
        return FetchMountainLocationUseCaseImpl(repository: makeMountainLocationRepository())
    }
    
    private func makeFetchMountainInfoUseCase() -> FetchMountainInfoUseCase {
        return FetchMountainInfoUseCaseImpl(repository: makeMountainInfoRepository())
    }
    
    private func makeFetchCoordinateUseCase() -> FetchCoordinateUseCase {
        return FetchCoordinateUseCaseImpl(repository: makeGeocodeRepository())
    }
    
    private func makeFetchWeeklyForecastUseCase() -> FetchWeeklyForecastUseCase {
        return FetchWeeklyForecastUseCaseImpl(repository: makeForecastRepository())
    }

    // MARK: - Repositories
    private func makeMountainLocationRepository() -> MountainLocationRepository {
        return JSONMountainLocationRepositoryImpl()
    }
    
    private func makeMountainInfoRepository() -> MountainInfoRepository {
        return JSONMountainInfoRepositoryImpl()
    }
    
    private func makeGeocodeRepository() -> GeocodeRepository {
        switch configuration.environment {
        case .release, .dev:
            return DefaultGeocodeRepositoryImpl()
        case .dummy:
            return DummyGeocodeRepositoryImpl()
        }
    }

    private func makeForecastRepository() -> ForecastRepository {
        switch configuration.environment {
        case .release, .dev:
            return DefaultForecastRepositoryImpl()
        case .dummy:
            return DummyForecastRepositoryImpl()
        }
    }
}
