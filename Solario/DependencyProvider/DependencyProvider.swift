//
//  DependencyProvider.swift
//  Solario
//
//  Created by Hermann W. on 31.01.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

import Foundation

class DependencyProvider: DependencyProviderProtocol {

    lazy var timeService: TimeServiceProtocol = TimeService()

    lazy var appearance: AppearanceProtocol = Appearance()

    lazy var dataInteractor: DataInteractorProtocol = DataInteractor(reportFactory: self.reportFactory,
                                                                     loader: self.dataLoader,
                                                                     processor: self.dataProcessor,
                                                                     rawStorage: self.rawDataStorage)

    // MARK: -

    private lazy var reportFactory: ReportFactoryProtocol = ReportFactory()

    private lazy var dataLoader: DataLoaderProtocol = DataLoader(rawStorage: self.rawDataStorage)

    private lazy var dataProcessor: DataProcessorProtocol = DataProcessor()

    private lazy var rawDataStorage: RawDataStorageProtocol = RawDataStorage(userDefaults: UserDefaults.standard)
}
