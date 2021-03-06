//
//  NOAA27DayOutlookParser.swift
//  Solario
//
//  Created by Hermann Wagenleitner on 13/06/2017.
//  Copyright © 2017 Hermann Wagenleitner. All rights reserved.
//

import Foundation

class NOAA27DayOutlookParser: RawDataParserProtocol, NOAAParserProtocol {

    private let tableHeaderKey = "#  Date"

    private let tableDateFormat = "yyyy MMM dd"

    private lazy var tableDateFormatter: DateFormatter = self.dateFormatter(format: self.tableDateFormat)

    // MARK: - RawDataParserProtocol

    var rawDataFile: RawDataFile?

    var issueDate: Date? {
        guard let issuedLine = firstLineBegins(with: issuedKey) else {
            return nil
        }
        return issueDateFromLine(issuedLine)
    }

    func items(setPriority priority: DataItemPriority) throws -> [DataItem] {

        guard let lines = rawDataFile?.lines else {
            throw ParserError.noDataFile
        }

        guard let tableHeaderIndex = firstLineIndexBegins(with: tableHeaderKey) else {
            throw ParserError.keyNotFound(tableHeaderKey)
        }

        let dataLinesStartIndex = tableHeaderIndex + 1
        let dataLinesEndIndex = lines.count - 1

        var items: [DataItem] = []

        for lineIndex in dataLinesStartIndex...dataLinesEndIndex {

            let line = lines[lineIndex]

            guard line.count > 10 else {
                continue
            }

            if let item = try? dataItem(line: line, priority: priority) {
                items.append(item)
            }
        }

        return items
    }

    // MARK: -

    private func dataItem(line: String, priority: DataItemPriority) throws -> DataItem? {

        let dateEndIndex = line.index(line.startIndex, offsetBy: 11)

        let dateString = String(line[...dateEndIndex])

        guard let date = tableDateFormatter.date(from: dateString) else {
            throw ParserError.unknownDateFormat(dateString)
        }

        let valueChar = line[line.index(line.endIndex, offsetBy: -1)]

        let value = (String(valueChar) as NSString).floatValue

        if let dateInterval = dateInterval(from: date, eighth: nil) {
            return DataItem(value: value, dateInterval: dateInterval, isForecast: true, priority: priority)
        }
        return nil
    }
}
