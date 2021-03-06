//
//  GFZMonthFactParser.swift
//  Solario
//
//  Created by Hermann Wagenleitner on 03/07/2017.
//  Copyright © 2017 Hermann Wagenleitner. All rights reserved.
//

import Foundation

class GFZMonthFactParser: RawDataParserProtocol {

    private let longWhitespacesRegex = try! NSRegularExpression(pattern: "[ ]+", options: [])

    private let dateFormat = "yyMMdd"

    private lazy var dateFormatter: DateFormatter = self.dateFormatter(format: self.dateFormat)

    private let valueStep: Float = 1 / 3

    // MARK: - RawDataParserProtocol

    var rawDataFile: RawDataFile?

    var issueDate: Date?

    func items(setPriority priority: DataItemPriority) throws -> [DataItem] {

        guard let lines = rawDataFile?.lines else {
            throw ParserError.noDataFile
        }

        var items: [DataItem] = []

        for line in lines {

            var preparedLine = removeLongWhitespaces(fromText: line)

            preparedLine = preparedLine.trimmingCharacters(in: .whitespaces)

            let lineComps = preparedLine.split(separator: " ")

            guard lineComps.count > 1 else {
                continue
            }

            let dateString = String(lineComps.first!)

            guard let date = dateFormatter.date(from: dateString) else {
                continue
            }

            let eightsCount = min(9, lineComps.count) - 1

            for eighth in 1...eightsCount {

                let rawValue = String(lineComps[eighth])

                guard let value = value(fromRaw: rawValue) else {
                    throw ParserError.unrecognizedFormat
                }

                if let dateInterval = dateInterval(from: date, eighth: eighth) {
                    let item = DataItem(value: value, dateInterval: dateInterval, isForecast: false, priority: priority)
                    items.append(item)
                }
            }
        }

        return items
    }

    // MARK: -

    private func removeLongWhitespaces(fromText text: String) -> String {
        let range = NSMakeRange(0, text.count)
        return longWhitespacesRegex.stringByReplacingMatches(in: text,
                                                             options: [],
                                                             range: range,
                                                             withTemplate: " ")
    }

    private func dateFormatter(format: String) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter
    }

    private func value(fromRaw raw: String) -> Float? {
        guard
            raw.count == 2,
            let integerValue = Int(String(raw.first!)) else {
                return nil
        }
        var value = Float(integerValue)
        let half = raw.last!
        if half == "+" {
            value += valueStep
        } else if half == "-" {
            value -= valueStep
        }
        return value
    }
}
