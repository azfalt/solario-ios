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

    let url: URL

    private(set) var parser: DataFileParser

    let title: String

    let priority: ReportPriority

    var rawDataFile: RawDataFile? {
        set {
            parser.rawDataFile = newValue
            parse()
        }
        get {
            return parser.rawDataFile
        }
    }

    private func parse() {
        loadDate = Date()
        do {
            items = try parser.items()
        } catch {
            print(error.localizedDescription)
            items = nil
        }
        issueDate = parser.issueDate
    }

    private(set) var items: [DataItem]?

    private(set) var loadDate: Date?

    private(set) var issueDate: Date?

    var isLoading: Bool = false

    var isLoaded: Bool {
        return rawDataFile != nil
    }

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

    init(url: URL, parser: DataFileParser, title: String, priority: ReportPriority) {
        self.url = url
        self.parser = parser
        self.title = title
        self.priority = priority
    }
}
