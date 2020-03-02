//
//  Report.swift
//  Solario
//
//  Created by Hermann Wagenleitner on 03/08/2017.
//  Copyright © 2017 Hermann Wagenleitner. All rights reserved.
//

import Foundation

class Report: ReportProtocol {

    private(set) var parser: RawDataParserProtocol

    private(set) var loadDate: Date?

    private(set) var issueDate: Date?

    init(url: URL, parser: RawDataParserProtocol, priority: DataItemPriority) {
        self.url = url
        self.parser = parser
        self.priority = priority
    }

    // MARK: - ReportProtocol

    let url: URL

    let priority: DataItemPriority

    private(set) var items: [DataItem]?

    var rawDataFile: RawDataFile? {
        get {
            return parser.rawDataFile
        }
    }

    func setRawDataFile(_ file: RawDataFile) {
        parser.rawDataFile = file
        parse()
    }

    // MARK: -

    private func parse() {
        loadDate = Date()
        do {
            items = try parser.items(setPriority: priority)
        } catch {
            print(error.localizedDescription)
            items = nil
        }
        issueDate = parser.issueDate
    }
}
