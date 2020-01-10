//
//  DataFileParser.swift
//  Solario
//
//  Created by Hermann Wagenleitner on 13/06/2017.
//  Copyright © 2017 Hermann Wagenleitner. All rights reserved.
//

import Foundation

enum ParserError: Error {

    case unrecognizedFormat

    case keyNotFound(String)

    case unknownDateFormat(String)

    case noDataFile
}

protocol DataFileParser {

    var calendar: Calendar { get }

    var rawDataFile: RawDataFile? { get set }

    var issueDate: Date? { get }

    func items() throws -> [DataItem]
}

extension DataFileParser {

    var calendar: Calendar {
        return Calendar.current
    }

    func dateComponents(from date: Date, eighth: Int?) -> DataItemDateComponents {
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return DataItemDateComponents(year: year, month: month, day: day, eighth: eighth)
    }
    
    func firstLineIndexBegins(with prefix: String) -> Int? {
        return rawDataFile?.lines.firstIndex(where: {
            return $0.hasPrefix(prefix)
        })
    }

    func firstLineBegins(with prefix: String) -> String? {
        if let index = firstLineIndexBegins(with: prefix) {
            return rawDataFile?.lines[index]
        }
        return nil
    }
}
