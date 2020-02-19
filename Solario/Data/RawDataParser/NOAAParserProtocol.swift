//
//  NOAAParserProtocol.swift
//  Solario
//
//  Created by Hermann Wagenleitner on 13/06/2017.
//  Copyright © 2017 Hermann Wagenleitner. All rights reserved.
//

import Foundation

protocol NOAAParserProtocol {}

extension NOAAParserProtocol {

    var locale: Locale {
        return Locale(identifier: "en_US_POSIX")
    }
    
    var issuedKey: String {
        return ":Issued:"
    }

    private var issueDateForamt: String {
        return "yyyy MMM dd HHmm z"
    }

    func dateFormatter(format: String) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = locale
        return dateFormatter
    }

    func issueDateFromLine(_ line: String) -> Date? {
        let index = line.index(issuedKey.endIndex, offsetBy: 1)
        let dateString = String(line[index...])
        let dateFormatter = self.dateFormatter(format: issueDateForamt)
        let date = dateFormatter.date(from: dateString)
        return date
    }
}
