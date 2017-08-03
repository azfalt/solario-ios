//
//  Report.swift
//  Solario
//
//  Created by Herman Wagenleitner on 03/08/2017.
//  Copyright © 2017 Herman Wagenleitner. All rights reserved.
//

import Foundation

class Report {

    var title: String?

    var rawDataFile: RawDataFile?

    var items: [DataItem]?

    var loadDate: Date?

    var issueDate: Date?

    var isLoading: Bool = false

    var fileURL: URL?

    private let retreiver = RawDataRetreiver()

    init() {
        configure()
    }

    internal func configure() {}

    public func load(completion: (() -> Void)? = nil) {
        guard let fileURL = fileURL else {
            return
        }
        isLoading = true
        retreiver.retreiveRawDataFile(url: fileURL, completion: { [weak self] rawDataFile in
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
    
    internal func createParser(rawDataFile: RawDataFile) -> DataFileParser? {
        return nil
    }
}
