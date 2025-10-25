//
//  AppDelegate.swift
//  Oreum
//
//  Created by 김영훈 on 9/25/25.
//

import UIKit
import Data
import FirebaseCore
import Core

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // release 환경에서만 Firebase 설정
        if AppConfiguration.current.environment == .release {
            FirebaseApp.configure()
        }
        NetworkManager.shared.startMonitoring()

        // 만료된 캐시 정리
        Task {
            await NetworkManager.shared.cleanExpiredCache()
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}
