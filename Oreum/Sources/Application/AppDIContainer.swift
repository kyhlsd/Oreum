//
//  AppDIContainer.swift
//  Oreum
//
//  Created by 김영훈 on 9/25/25.
//

import Foundation
import Presentation

final class AppDIContainer {
    
    let appConfiguration: AppConfiguration
    
    init(appConfiguration: AppConfiguration) {
        self.appConfiguration = appConfiguration
    }
    
    func makeRecordSceneDIContainer() -> RecordSceneDIContainer {
        return RecordSceneDIContainer()
    }
    
    func makeMeasureSceneDIContainer() -> MeasureSceneDIContainer {
        return MeasureSceneDIContainer()
    }
    
    func makeMapSceneDIContainer() -> MapSceneDIContainer {
        return MapSceneDIContainer()
    }
    
    func makeSearchSceneDIContainer() -> SearchSceneDIContainer {
        return SearchSceneDIContainer()
    }
}
