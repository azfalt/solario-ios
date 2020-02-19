//
//  NOAA3DayForecastParser.swift
//  Solario
//
//  Created by Hermann Wagenleitner on 13/06/2017.
//  Copyright © 2017 Hermann Wagenleitner. All rights reserved.
//

import Foundation

class NOAA3DayForecastParser: RawDataParserProtocol, NOAAParserProtocol {

    private let titleKey = "NOAA Kp index breakdown"

    private let titlePeriodDateFormat = "MMM dd yyyy"

    private let eighthKeys = ["00-03UT", "03-06UT", "06-09UT", "09-12UT", "12-15UT", "15-18UT", "18-21UT", "21-00UT"]

    // MARK: - RawDataParserProtocol

    var rawDataFile: RawDataFile?

    var issueDate: Date? {
        guard let issuedLine = firstLineBegins(with: issuedKey) else {
            return nil
        }
        return issueDateFromLine(issuedLine)
    }

    func items(setPriority priority: DataItemPriority) throws -> [DataItem] {

        guard rawDataFile != nil else {
            throw ParserError.noDataFile
        }

        guard let titleLine = firstLineBegins(with: titleKey) else {
            throw ParserError.keyNotFound(titleKey)
        }

        let index = titleLine.index(titleKey.endIndex, offsetBy: 1)
        let datesString = String(titleLine[index...])

        let dateStrings = datesString.components(separatedBy: "-")

        guard dateStrings.count == 2 else {
            throw ParserError.unrecognizedFormat
        }

        let dateFormatter = self.dateFormatter(format: titlePeriodDateFormat)

        guard let date3 = dateFormatter.date(from: dateStrings[1]) else {
            throw ParserError.unknownDateFormat(dateStrings[1])
        }
        let dayTimeInterval: TimeInterval = -3600 * 24
        let date2 = date3.addingTimeInterval(dayTimeInterval)
        let date1 = date2.addingTimeInterval(dayTimeInterval)

        var items1: [DataItem] = []
        var items2: [DataItem] = []
        var items3: [DataItem] = []

        for (index, key) in eighthKeys.enumerated() {

            guard let line = firstLineBegins(with: key) else {
                throw ParserError.keyNotFound(key)
            }

            let eighth = index + 1

            if let dataItem1 = dataItem(date: date1, eighth: eighth, line: line, offset: 15, priority: priority) {
                items1.append(dataItem1)
            }
            if let dataItem2 = dataItem(date: date2, eighth: eighth, line: line, offset: 26, priority: priority) {
                items2.append(dataItem2)
            }
            if let dataItem3 = dataItem(date: date3, eighth: eighth, line: line, offset: 37, priority: priority) {
                items3.append(dataItem3)
            }
        }

        return items1 + items2 + items3
    }

    // MARK: -

    private func dataItem(date: Date, eighth: Int, line: String, offset: Int, priority: DataItemPriority) -> DataItem? {
        let valueChar = line[line.index(line.startIndex, offsetBy: offset)]
        let value = (String(valueChar) as NSString).floatValue
        if let dateInterval = dateInterval(from: date, eighth: eighth) {
            return DataItem(value: value, dateInterval: dateInterval, isForecast: true, priority: priority)
        }
        return nil
    }
}
