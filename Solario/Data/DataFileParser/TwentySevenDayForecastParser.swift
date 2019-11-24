//
//  TwentySevenDayForecastParser.swift
//  Solario
//
//  Created by Hermann Wagenleitner on 13/06/2017.
//  Copyright © 2017 Hermann Wagenleitner. All rights reserved.
//

import Foundation

class TwentySevenDayForecastParser: DataFileParser, NOAADataFileParser {

    var rawDataFile: RawDataFile

    init(rawDataFile: RawDataFile) {
        self.rawDataFile = rawDataFile
    }

    private let tableHeaderKey = "#  Date"

    private let tableDateFormat = "yyyy MMM dd"

    private lazy var tableDateFormatter: DateFormatter = self.dateFormatter(format: self.tableDateFormat)

    func items() throws -> [DataItem] {

        guard let tableHeaderIndex = firstLineIndexBegins(with: tableHeaderKey) else {
            throw ParserError.keyNotFound(tableHeaderKey)
        }

        let dataLinesStartIndex = tableHeaderIndex + 1
        let dataLinesEndIndex = rawDataFile.lines.count - 1

        var items: [DataItem] = []

        for lineIndex in dataLinesStartIndex...dataLinesEndIndex {

            let line = rawDataFile.lines[lineIndex]

            guard line.count > 10 else {
                continue
            }

            if let item = try? dataItem(line: line) {
                items.append(item)
            }
        }

        return items
    }

    private func dataItem(line: String) throws -> DataItem {

        let dateEndIndex = line.index(line.startIndex, offsetBy: 11)

        let dateString = String(line[...dateEndIndex])

        guard let date = tableDateFormatter.date(from: dateString) else {
            throw ParserError.unknownDateFormat(dateString)
        }

        let valueChar = line[line.index(line.endIndex, offsetBy: -1)]

        let value = (String(valueChar) as NSString).floatValue

        let dateComponents = self.dateComponents(from: date, eighth: nil)

        return DataItem(value: value, dateComponents: dateComponents, isForecast: true)
    }

    var issueDate: Date? {
        guard let issuedLine = firstLineBegins(with: issuedKey) else {
            return nil
        }
        return issueDateFromLine(issuedLine)
    }
}
