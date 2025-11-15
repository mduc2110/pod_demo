//
//  AppDelegate.swift
//  PrintOnDemand
//
//  Created by duczxje on 15/11/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    private let fileStoreManager = PlatformFileStoreManager()

    private lazy var dataPortProvider = PlatformDataPortProvider()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?,
    ) -> Bool {
        // Override point for customization after application launch.
        installPlatformPrinter()

        initComponents()

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions,
    ) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role,
        )
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>,
    ) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    private func installPlatformPrinter() {
        #if DEBUG
            Logger.i("AppDelegate", "PlatformLogPrinter not Found")
        #else
            installLogPrinter(printer: SwallowLogPrinter())
        #endif
    }

    private func initComponents() {
        // Install App deps
        AppModule().install()

        // Install Data deps
        DataModule(baseURL: AppConfig.BASE_URL).install()

        // Install Domain deps
        DomainModule().install()

        // Install Common deps
        CommonModule(
            fileStoreManager: fileStoreManager,
            dataPortProvider: dataPortProvider,
        ).install()
    }
}
