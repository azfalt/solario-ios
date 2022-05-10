//
//  Calendar.swift
//  Solario
//
//  Created by Hermann W. on 18.02.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

import Foundation

extension Calendar {

    func endOfDay(for date: Date) -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        let startOfDay = self.startOfDay(for: date)
        return self.date(byAdding: components, to: startOfDay)!
    }
    
    func begin(for date: Date) -> Date {
        let components = dateComponents([.year, .month, .day], from: date)
        return self.date(from: components)!
    }
}
