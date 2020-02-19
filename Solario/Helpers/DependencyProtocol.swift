//
//  DependencyProtocol.swift
//  Solario
//
//  Created by Hermann W. on 01.02.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

import Foundation

protocol DependencyProtocol {}

extension DependencyProtocol {

    var timeService: TimeServiceProtocol {
        return dependencyProvider.timeService
    }

    var appearance: AppearanceProtocol {
        return dependencyProvider.appearance
    }

    var dataInteractor: DataInteractorProtocol {
        return dependencyProvider.dataInteractor
    }

    private var dependencyProvider: DependencyProviderProtocol {
        return appDelegate.dependencyProvider
    }

    private var appDelegate: AppDelegate {
        var appDelegate: AppDelegate!
        if Thread.isMainThread {
            appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        } else {
            DispatchQueue.main.sync {
                appDelegate = (UIApplication.shared.delegate as! AppDelegate)
            }
        }
        return appDelegate
    }
}
