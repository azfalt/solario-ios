//
//  DependencyProvider.swift
//  Solario
//
//  Created by Hermann W. on 31.01.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

import Foundation

class DependencyProvider: DependencyProviderProtocol {

    lazy var reportsInteractor = ReportsInteractor()

    lazy var rawDataRetriever: RawDataRetrieverProtocol = RawDataRetriever()

    lazy var rawDataStorage: RawDataStorageProtocol = RawDataStorage()

    lazy var timeService: TimeServiceProtocol = TimeService()
}
