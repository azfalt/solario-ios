//
//  MonthFactParser.swift
//  Solario
//
//  Created by Hermann Wagenleitner on 03/07/2017.
//  Copyright © 2017 Hermann Wagenleitner. All rights reserved.
//

import Foundation

class MonthFactParser: DataFileParser {

    var rawDataFile: RawDataFile

    var issueDate: Date?

    init(rawDataFile: RawDataFile) {
        self.rawDataFile = rawDataFile
    }

    func items() throws -> [DataItem] {

        var items: [DataItem] = []

        for line in rawDataFile.lines {

            var preparedLine = removeLongWhitespaces(fromText: line)

            preparedLine = preparedLine.trimmingCharacters(in: .whitespaces)

//            let lineComps = preparedLine.split(separator: " ") // swift 4
            let lineComps = preparedLine.components(separatedBy: " ") // swift 3

            guard lineComps.count > 1 else {
                continue
            }

            let dateString = lineComps.first!

            guard let date = dateFormatter.date(from: dateString) else {
                continue
            }

            let eightsCount = min(9, lineComps.count) - 1

            for eighth in 1...eightsCount {

                let rawValue = lineComps[eighth]

                guard let value = value(fromRaw: rawValue) else {
                    throw ParserError.unrecognizedFormat
                }

                let dateComponents = self.dateComponents(from: date, eighth: eighth)
                let item = DataItem(value: value, dateComponents: dateComponents, isForecast: false)
                items.append(item)
            }
        }

        return items
    }

    private let longWhitespacesRegex = try! NSRegularExpression(pattern: "[ ]+", options: [])

    private func removeLongWhitespaces(fromText text: String) -> String {
        let range = NSMakeRange(0, text.characters.count)
        return longWhitespacesRegex.stringByReplacingMatches(in: text,
                                                             options: [],
                                                             range: range,
                                                             withTemplate: " ")
    }

    private let dateFormat = "yyMMdd"

    private func dateFormatter(format: String) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter
    }

    private lazy var dateFormatter: DateFormatter = self.dateFormatter(format: self.dateFormat)

    private let valueStep: Float = 1 / 3

    private func value(fromRaw raw: String) -> Float? {
        guard
            raw.characters.count == 2,
            let integerValue = Int(String(raw.characters.first!)) else {
                return nil
        }
        var value = Float(integerValue)
        let half = raw.characters.last!
        if half == "+" {
            value += valueStep
        } else if half == "-" {
            value -= valueStep
        }
        return value
    }
}
