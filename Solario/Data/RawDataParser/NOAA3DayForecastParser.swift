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

        let regex = try! NSRegularExpression(pattern: "[0-9]+\\.[0-9]+")

        for (index, key) in eighthKeys.enumerated() {

            guard let line = firstLineBegins(with: key) else {
                throw ParserError.keyNotFound(key)
            }

            let eighth = index + 1

            let results = regex.matches(in: line, range: NSRange(line.startIndex..., in: line))

            let values: [Float?] = results.map {
                Float(line[Range($0.range, in: line)!])
            }

            if let dataItem = dataItem(date: date1, eighth: eighth, values: values, position: 0, priority: priority) {
                items1.append(dataItem)
            }
            if let dataItem = dataItem(date: date2, eighth: eighth, values: values, position: 1, priority: priority) {
                items2.append(dataItem)
            }
            if let dataItem = dataItem(date: date3, eighth: eighth, values: values, position: 2, priority: priority) {
                items3.append(dataItem)
            }
        }

        return items1 + items2 + items3
    }

    // MARK: -

    private func dataItem(date: Date, eighth: Int, values: [Float?], position: Int, priority: DataItemPriority) -> DataItem? {
        if
            values.count > position,
            let value = values[position],
            let dateInterval = dateInterval(from: date, eighth: eighth)
        {
            return DataItem(value: value, dateInterval: dateInterval, isForecast: true, priority: priority)
        }
        return nil
    }
}
