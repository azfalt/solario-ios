//
//  ParserError.swift
//  Solario
//
//  Created by Hermann Wagenleitner on 13/06/2017.
//  Copyright © 2017 Hermann Wagenleitner. All rights reserved.
//

import Foundation

public enum ParserError: Error {

    case unrecognizedFormat

    case keyNotFound(String)

    case unknownDateFormat(String)
}
