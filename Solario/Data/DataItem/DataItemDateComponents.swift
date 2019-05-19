//
//  DataItemDateComponents.swift
//  Solario
//
//  Created by Hermann Wagenleitner on 13/06/2017.
//  Copyright © 2017 Hermann Wagenleitner. All rights reserved.
//

import Foundation

struct DataItemDateComponents {

    let year: Int

    let month: Int

    let day: Int

    let eighth: Int?
}

extension DataItemDateComponents {

    var date: Date? {
        let dc = NSDateComponents()
        dc.timeZone = TimeZone(abbreviation: "UTC")
        dc.calendar = Calendar.current
        dc.year = year
        dc.month = month
        dc.day = day
        if let eighth = eighth {
            dc.hour = 3 * (eighth - 1)
        }
        return dc.date
    }
}
