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

    var reportsInteractor: ReportsInteractor {
        return dependencyProvider.reportsInteractor
    }

    var rawDataRetriever: RawDataRetrieverProtocol {
        return dependencyProvider.rawDataRetriever
    }

    var rawDataStorage: RawDataStorageProtocol {
        return dependencyProvider.rawDataStorage
    }

    var timeService: TimeServiceProtocol {
        return dependencyProvider.timeService
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
