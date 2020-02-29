//
//  AppDelegate.swift
//  Solario
//
//  Created by Hermann Wagenleitner on 05/03/2017.
//  Copyright © 2017 Hermann Wagenleitner. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, DependencyProtocol {
    
    var window: UIWindow?

    let dependencyProvider = DependencyProvider()
    
    // MARK: - UIApplicationDelegate
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        configureWindow()
        configureAppearance()
        configureTimeService()

        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)

        return true
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        dataInteractor.loadData(completion: { success in
            completionHandler(success ? .newData : .noData)
        })
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        dataInteractor.loadData(completion: nil)
    }

    // MARK: -

    private func configureWindow() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let rootVC = CalendarViewController()
        let nc = UINavigationController(rootViewController: rootVC)
        window.rootViewController = nc
        window.makeKeyAndVisible()
        self.window = window
    }
    
    private func configureAppearance() {
        window?.tintColor = appearance.tintColor
    }

    private func configureTimeService() {
        timeService.day.addObserver(self) { [unowned self] day in
            self.dataInteractor.loadData(completion: nil)
        }
        timeService.start()
    }
}
