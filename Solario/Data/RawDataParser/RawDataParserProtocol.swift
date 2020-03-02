//
//  RawDataParserProtocol.swift
//  Solario
//
//  Created by Hermann Wagenleitner on 13/06/2017.
//  Copyright © 2017 Hermann Wagenleitner. All rights reserved.
//

import Foundation

protocol RawDataParserProtocol {

    var rawDataFile: RawDataFile? { get set }

    var issueDate: Date? { get }

    func items(setPriority priority: DataItemPriority) throws -> [DataItem]
}

extension RawDataParserProtocol {

    func dateInterval(from date: Date, eighth: Int?) -> DateInterval? {
        let cal = Constants.calendar
        let year = cal.component(.year, from: date)
        let month = cal.component(.month, from: date)
        let day = cal.component(.day, from: date)
        let components = DataItemDateComponents(year: year, month: month, day: day, eighth: eighth)
        return components.dateInterval
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
