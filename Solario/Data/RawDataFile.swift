//
//  RawDataFile.swift
//  Solario
//
//  Created by Herman Wagenleitner on 13/06/2017.
//  Copyright © 2017 Herman Wagenleitner. All rights reserved.
//

import Foundation

struct RawDataFile {

    let text: String

    var lines: [String] {
        return text.components(separatedBy: .newlines)
    }
}
