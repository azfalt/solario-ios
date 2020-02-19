//
//  ParserError.swift
//  Solario
//
//  Created by Hermann W. on 16.02.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

import Foundation

enum ParserError: Error {

    case unrecognizedFormat

    case keyNotFound(String)

    case unknownDateFormat(String)

    case noDataFile
}
