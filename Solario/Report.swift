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

    var itemsDateInterval: DateInterval? {
        guard let items = items else {
            return nil
        }
        var start, end: Date?
        for item in items {
            let itemStart = item.dateInterval.start
            if start == nil {
                start = itemStart
            } else if itemStart < start! {
                start = itemStart
            }
            let itemEnd = item.dateInterval.end
            if end == nil {
                end = itemEnd
            } else if itemEnd > end! {
                end = itemEnd
            }
        }
        if let start = start, let end = end {
            return DateInterval(start: start, end: end)
        }
        return nil
    }

    init(url: URL, parser: DataFileParser, title: String, priority: ReportPriority) {
        self.url = url
        self.parser = parser
        self.title = title
        self.priority = priority
    }
}
