//
//  SearchSceneDIContainer.swift
//  Presentation
//
//  Created by 김영훈 on 9/26/25.
//

import UIKit
import Domain
import Data
import Core

public final class SearchSceneDIContainer {

    private let configuration: EnvironmentConfigurable

    public init(configuration: EnvironmentConfigurable) {
        self.configuration = configuration
    }

    public func makeSearchSceneFlowCoordinator(navigationController: UINavigationController) -> SearchSceneFlowCoordinator {
        return SearchSceneFlowCoordinator(navigationController: navigationController, dependencies: self)
    }
}

extension SearchSceneDIContainer: SearchSceneFlowCoordinatorDependencies {

    // MARK: - ViewControllers
    func makeSearchViewController() -> SearchViewController {
        return SearchViewController(viewModel: makeSearchViewModel())
    }

    func makeMountainInfoViewController(mountainInfo: MountainInfo) -> MountainInfoViewController {
        return MountainInfoViewController(viewModel: makeMountainInfoViewModel(mountainInfo: mountainInfo))
    }

    // MARK: - ViewModels
    private func makeSearchViewModel() -> SearchViewModel {
        return SearchViewModel(
            fetchMountainsUseCase: makeFetchMountainsUseCase(),
            fetchRecentSearchesUseCase: makeFetchRecentSearchesUseCase(),
            saveRecentSearchUseCase: makeSaveRecentSearchUseCase(),
            deleteRecentSearchUseCase: makeDeleteRecentSearchUseCase(),
            clearRecentSearchesUseCase: makeClearRecentSearchesUseCase()
        )
    }

    private func makeMountainInfoViewModel(mountainInfo: MountainInfo) -> MountainInfoViewModel {
        return MountainInfoViewModel(
            fetchCoordinateUseCase: makeFetchCoordinateUseCase(),
            fetchWeeklyForecastUseCase: makeFetchWeeklyForecastUseCase(),
            mountainInfo: mountainInfo
        )
    }

    // MARK: - UseCases
    private func makeFetchMountainsUseCase() -> FetchMountainsUseCase {
        return FetchMountainsUseCaseImpl(repository: makeMountainInfoRepository())
    }

    private func makeFetchRecentSearchesUseCase() -> FetchRecentSearchesUseCase {
        return FetchRecentSearchesUseCaseImpl(repository: makeRecentSearchRepository())
    }

    private func makeSaveRecentSearchUseCase() -> SaveRecentSearchUseCase {
        return SaveRecentSearchUseCaseImpl(repository: makeRecentSearchRepository())
    }

    private func makeDeleteRecentSearchUseCase() -> DeleteRecentSearchUseCase {
        return DeleteRecentSearchUseCaseImpl(repository: makeRecentSearchRepository())
    }

    private func makeClearRecentSearchesUseCase() -> ClearRecentSearchesUseCase {
        return ClearRecentSearchesUseCaseImpl(repository: makeRecentSearchRepository())
    }

    private func makeFetchCoordinateUseCase() -> FetchCoordinateUseCase {
        return FetchCoordinateUseCaseImpl(repository: makeGeocodeRepository())
    }
    
    private func makeFetchWeeklyForecastUseCase() -> FetchWeeklyForecastUseCase {
        return FetchWeeklyForecastUseCaseImpl(repository: makeForecastRepository())
    }

    // MARK: - Repositories
    private func makeMountainInfoRepository() -> MountainInfoRepository {
        return JSONMountainInfoRepositoryImpl()
    }

    private func makeRecentSearchRepository() -> RecentSearchRepository {
        do {
            return try RealmRecentSearchRepositoryImpl()
        } catch {
            print("Failed to initialize Realm: \(error.localizedDescription)")
            return ErrorRecentSearchRepositoryImpl()
        }
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
