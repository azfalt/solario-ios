//
//  TimeService.swift
//  Solario
//
//  Created by Hermann W. on 26.01.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

import Foundation

class TimeService {

    struct Notifications {

        static let DayDidChange = Notification.Name("TimeService.DayDidChange")
    }

    private var timer: Timer?

    private var lastDay: Int = 0

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            self?.checkForCahnges()
        })
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    @objc private func checkForCahnges() {
        let day = Calendar.current.component(.day, from: Date())
        if lastDay > 0 && day != lastDay {
            NotificationCenter.default.post(name: Notifications.DayDidChange, object: nil)
        }
        lastDay = day
    }
}
