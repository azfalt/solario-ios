//
//  DependencyProviderProtocol.swift
//  Solario
//
//  Created by Hermann W. on 01.02.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

import Foundation

protocol DependencyProviderProtocol {

    var reportsInteractor: ReportsInteractor { get }

    var rawDataRetriever: RawDataRetrieverProtocol { get }

    var rawDataStorage: RawDataStorageProtocol { get }

    var timeService: TimeServiceProtocol { get }
}
