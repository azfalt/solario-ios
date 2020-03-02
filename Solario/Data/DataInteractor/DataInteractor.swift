//
//  DataInteractor.swift
//  Solario
//
//  Created by Hermann Wagenleitner on 10/09/2017.
//  Copyright © 2017 Hermann Wagenleitner. All rights reserved.
//

import Foundation

class DataInteractor: DataInteractorProtocol {

    private let reportFactory: ReportFactoryProtocol

    private let loader: DataLoaderProtocol

    private let processor: DataProcessorProtocol

    private let rawStorage: RawDataStorageProtocol

    private var itemsByDate: [Date:[DataItem]] = [:]

    private var maxValuesByDate = [Date:Float]()

    private lazy var reports: [ReportProtocol] = self.reportFactory.createReports()

    private var allReportItems: [DataItem] {
        return reports.flatMap({ (report: ReportProtocol) -> [DataItem] in
            return report.items ?? []
        })
    }

    private var isPreparing: Bool = false {
        didSet {
            updateProcessingState()
        }
    }

    private var isLoading: Bool = false {
        didSet {
            updateProcessingState()
        }
    }

    required init(reportFactory: ReportFactoryProtocol, loader: DataLoaderProtocol, processor: DataProcessorProtocol, rawStorage: RawDataStorageProtocol) {
        self.reportFactory = reportFactory
        self.loader = loader
        self.processor = processor
        self.rawStorage = rawStorage
        tryLoadStoredReports()
    }

    // MARK: - DataInteractorProtocol

    private(set) var isProcessing: Observable<Bool> = Observable(value: false)

    private(set) var dateInterval: DateInterval?

    func maxValue(forDate date: Date) -> Float? {
        return maxValuesByDate[date]
    }

    func items(forDate date: Date) -> [DataItem] {
        return itemsByDate[date] ?? []
    }

    func loadData(completion: LoadCompletion? = nil) {
        isLoading = true
        loader.load(reports: reports) { [weak self] success in
            defer {
                completion?(success)
            }
            guard let self = self else {
                return
            }
            if (success) {
                self.prepareData()
            }
            self.isLoading = false
        }
    }

    // MARK: -

    private func updateProcessingState() {
        isProcessing.value = isLoading || isPreparing
    }

    private func prepareData() {
        isPreparing = true
        itemsByDate = processor.prepare(items: allReportItems)
        maxValuesByDate = processor.calculateMaxValues(itemsByDate: itemsByDate)
        dateInterval = processor.dateInterval(dates: Array(itemsByDate.keys))
        isPreparing = false
    }

    private func tryLoadStoredReports() {
        var isLoaded = false
        for report in reports {
            if let file = rawStorage.rawDataFile(url: report.url) {
                report.setRawDataFile(file)
                isLoaded = true
            }
        }
        if isLoaded {
            prepareData()
        }
    }
}
