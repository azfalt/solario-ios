//
//  DependencyProvider.swift
//  Solario
//
//  Created by Hermann W. on 31.01.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

import Foundation

protocol DependencyProviderProtocol {

    var reportsInteractor: ReportsInteractor { get }

    var timeService: TimeServiceProtocol { get }
}

class DependencyProvider: DependencyProviderProtocol {

    let reportsInteractor = ReportsInteractor()

    let timeService: TimeServiceProtocol = TimeService()
}

protocol DependencyProtocol {}

extension DependencyProtocol {

    var reportsInteractor: ReportsInteractor {
        return dependencyProvider.reportsInteractor
    }

    var timeService: TimeServiceProtocol {
        return dependencyProvider.timeService
    }

    private var dependencyProvider: DependencyProviderProtocol {
        return appDelegate.dependencyProvider
    }

    private var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
}
