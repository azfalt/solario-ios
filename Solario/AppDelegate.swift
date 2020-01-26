//
//  AppDelegate.swift
//  Solario
//
//  Created by Hermann Wagenleitner on 05/03/2017.
//  Copyright © 2017 Hermann Wagenleitner. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let reportsInteractor = ReportsInteractor()

    lazy var timeService = TimeService()
    
    // MARK: - UIApplicationDelegate
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        let rootVC = CalendarViewController()
        rootVC.reportsInteractor = reportsInteractor
        let nc = UINavigationController(rootViewController: rootVC)
        window?.rootViewController = nc
        window?.makeKeyAndVisible()
        
        configureAppearance()
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)

        timeService.start()
        
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        reportsInteractor.loadReports(completion: {
            completionHandler(.newData)
        })
    }

    // MARK: - Helpers
    
    private func configureAppearance() {
        window?.tintColor = Appearance.tintColor
    }
}
