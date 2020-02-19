//
//  DataItem.swift
//  Solario
//
//  Created by Hermann Wagenleitner on 13/06/2017.
//  Copyright © 2017 Hermann Wagenleitner. All rights reserved.
//

import Foundation

struct DataItem {

    let value: Float

    let dateInterval: DateInterval

    let isForecast: Bool

    let priority: DataItemPriority
}

extension DataItem {

    var isCurrent: Bool {
        return dateInterval.contains(Date())
    }
}
