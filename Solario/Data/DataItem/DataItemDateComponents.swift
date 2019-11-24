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

    var beginDay: Date? {
        return baseDateComponents.date
    }

    var beginDate: Date? {
        let dc = baseDateComponents
        dc.hour = beginHour
        return dc.date
    }

    var endDate: Date? {
        let dc = baseDateComponents
        dc.hour = endHour
        return dc.date
    }

    var beginUTCDate: Date? {
        let dc = baseUTCDateComponents
        dc.hour = beginHour
        return dc.date
    }

    var endUTCDate: Date? {
        let dc = baseUTCDateComponents
        dc.hour = endHour
        return dc.date
    }

    var isCurrent: Bool {
        guard
            let beginDate = beginUTCDate,
            let endDate = endUTCDate else {
                return false
        }
        let now = Date();
        return beginDate <= now && endDate >= now
    }

    func hasTheSameBaseDate(as components: DataItemDateComponents) -> Bool {
        return year == components.year && month == components.month && day == components.day
    }

    private var baseDateComponents: NSDateComponents {
        let dc = NSDateComponents()
        dc.calendar = Calendar.current
        dc.year = year
        dc.month = month
        dc.day = day
        return dc
    }

    private var baseUTCDateComponents: NSDateComponents {
        let dc = baseDateComponents
        dc.timeZone = TimeZone(abbreviation: "UTC")
        return dc
    }

    private var beginHour: Int {
        return eighth == nil ? 0 : 3 * (eighth! - 1)
    }

    private var endHour: Int {
        return eighth == nil ? 24 : 3 * eighth!
    }
}
