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

    private var isBackgroung = true
    
    // MARK: - UIApplicationDelegate
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureWindow()
        configureAppearance()
        configureTimeService()
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        isBackgroung = true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if isBackgroung {
            dataInteractor.loadData(completion: nil)
        }
        isBackgroung = false
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
