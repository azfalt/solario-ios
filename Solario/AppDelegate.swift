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
    
    // MARK: - UIApplicationDelegate
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        let reportListVC = ReportListViewController()
        reportListVC.reportsInteractor = reportsInteractor
        let nc = UINavigationController(rootViewController: reportListVC)
        window?.rootViewController = nc
        window?.makeKeyAndVisible()
        
        configureAppearance()
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        reportsInteractor.loadReports(completion: {
            completionHandler(.newData)
        })
    }

    // MARK: - Helpers
    
    private func configureAppearance() {
        
        // UIWindow
        window?.tintColor = Appearance.tintColor
        
        // UINavigationBar
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: Appearance.textColor
        ]
        UINavigationBar.appearance().barTintColor = Appearance.navBarBgColor
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().barStyle = Appearance.navBarStyle
        
        // UITableView
        UITableView.appearance().backgroundColor = Appearance.secondaryBgColor
        UITableView.appearance().separatorColor = Appearance.separatorColor
        
        // UITableViewCell
        UITableViewCell.appearance().backgroundColor = Appearance.bgColor
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = Appearance.selectionColor
        UITableViewCell.appearance().selectedBackgroundView = selectedBackgroundView
        UITableViewCell.appearance().textLabel?.textColor = Appearance.textColor
    }
}
