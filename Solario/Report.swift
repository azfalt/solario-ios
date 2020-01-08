//
//  Report.swift
//  Solario
//
//  Created by Hermann Wagenleitner on 03/08/2017.
//  Copyright © 2017 Hermann Wagenleitner. All rights reserved.
//

import Foundation

enum ReportPriority: Int {

    case low

    case normal

    case high
}

typealias DateBounds = (earliest: Date, latest: Date)

class Report {

    var title: String?

    var rawDataFile: RawDataFile?

    var items: [DataItem]?

    var loadDate: Date?

    var issueDate: Date?

    var isLoading: Bool = false

    var fileURL: URL?

    var priority: ReportPriority = .normal

    var itemsDateBounds: DateBounds? {
        guard let items = items else {
            return nil
        }
        var earliest, latest: Date?
        for item in items {
            if let beginDate = item.dateComponents.beginUTCDate {
                if earliest == nil {
                    earliest = beginDate
                } else if beginDate < earliest! {
                    earliest = beginDate
                }
            }
            if let endDate = item.dateComponents.endUTCDate {
                if latest == nil {
                    latest = endDate
                } else if endDate > latest! {
                    latest = endDate
                }
            }
        }
        guard earliest != nil, latest != nil else {
            return nil
        }
        return (earliest: earliest!, latest: latest!)
    }

    private let retreiver = RawDataRetreiver()

    init() {
        configure()
    }

    func configure() {}

    func load(completion: (() -> Void)? = nil) {
        guard let fileURL = fileURL else {
            return
        }
        isLoading = true
        retreiver.retrieveRawDataFile(url: fileURL, completion: { [weak self] rawDataFile in
            guard
                let rawDataFile = rawDataFile,
                let parser = self?.createParser(rawDataFile: rawDataFile),
                let items = try? parser.items() else {
                    return
            }
            self?.rawDataFile = rawDataFile
            self?.loadDate = Date()
            self?.items = items
            self?.issueDate = parser.issueDate
            self?.isLoading = false
            completion?()
        })
    }
    
    func createParser(rawDataFile: RawDataFile) -> DataFileParser? {
        return nil
    }
}
