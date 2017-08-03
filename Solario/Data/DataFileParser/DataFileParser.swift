//
//  DataFileParser.swift
//  Solario
//
//  Created by Herman Wagenleitner on 13/06/2017.
//  Copyright © 2017 Herman Wagenleitner. All rights reserved.
//

import Foundation

protocol DataFileParser {

  var calendar: Calendar { get }

  var rawDataFile: RawDataFile { get }

  var issueDate: Date? { get }

  func items() throws -> [DataItem]
}

extension DataFileParser {

  var calendar: Calendar {
    return Calendar.current
  }

  internal func dateComponents(from date: Date, eighth: Int?) -> DataItemDateComponents {
    let year = calendar.component(.year, from: date)
    let month = calendar.component(.month, from: date)
    let day = calendar.component(.day, from: date)
    return DataItemDateComponents(year: year, month: month, day: day, eighth: eighth)
  }

  internal func firstLineIndexBegins(with prefix: String) -> Int? {
    return rawDataFile.lines.index(where: {
      return $0.hasPrefix(prefix)
    })
  }

  internal func firstLineBegins(with prefix: String) -> String? {
    if let index = firstLineIndexBegins(with: prefix) {
      return rawDataFile.lines[index]
    }
    return nil
  }

  // unused
  internal func firstPostfix(after key: String, offset: Int = 0) throws -> String {
    guard let line = firstLineBegins(with: key) else {
      throw ParserError.keyNotFound(key)
    }
    let index = line.index(key.endIndex, offsetBy: offset)
    return line.substring(from: index)
  }
}
