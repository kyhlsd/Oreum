//
//  AppDIContainer.swift
//  Oreum
//
//  Created by 김영훈 on 9/25/25.
//

import Foundation
import Presentation
import Core

final class AppDIContainer {

    let appConfiguration: AppConfiguration

    init(appConfiguration: AppConfiguration) {
        self.appConfiguration = appConfiguration
    }

    func makeRecordSceneDIContainer() -> RecordSceneDIContainer {
        return RecordSceneDIContainer(configuration: appConfiguration)
    }

    func makeMeasureSceneDIContainer() -> MeasureSceneDIContainer {
        return MeasureSceneDIContainer(configuration: appConfiguration)
    }

    func makeMapSceneDIContainer() -> MapSceneDIContainer {
        return MapSceneDIContainer(configuration: appConfiguration)
    }

    func makeSearchSceneDIContainer() -> SearchSceneDIContainer {
        return SearchSceneDIContainer(configuration: appConfiguration)
    }
}
