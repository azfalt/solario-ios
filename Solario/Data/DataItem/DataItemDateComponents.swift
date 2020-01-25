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

    var dateInterval: DateInterval? {
        let dc = baseDateComponents
        dc.hour = startHour
        let start = dc.date
        dc.hour = endHour
        let end = dc.date
        if let start = start, let end = end {
            return DateInterval(start: start, end: end)
        }
        return nil
    }

    private var baseDateComponents: NSDateComponents {
        let dc = NSDateComponents()
        dc.calendar = Calendar.current
        dc.year = year
        dc.month = month
        dc.day = day
        dc.timeZone = TimeZone(abbreviation: "UTC")
        return dc
    }

    private var startHour: Int {
        return eighth == nil ? 0 : 3 * (eighth! - 1)
    }

    private var endHour: Int {
        return eighth == nil ? 24 : 3 * eighth!
    }
}
