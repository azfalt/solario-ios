//
//  TimeService.swift
//  Solario
//
//  Created by Hermann W. on 26.01.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

import Foundation

class TimeService: TimeServiceProtocol {

    private static var currentDay: Int {
        return Calendar.current.component(.day, from: Date())
    }

    private(set) var day: Observable<Int>

    private weak var timer: Timer?

    init() {
        day = Observable(value: TimeService.currentDay)
    }

    deinit {
        stop()
    }

    func start() {
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
                self?.checkForChanges()
            })
        }
    }

    func stop() {
        DispatchQueue.main.async {
            self.timer?.invalidate()
            self.timer = nil
        }
    }

    private func checkForChanges() {
        let currentDay = TimeService.currentDay
        if currentDay != day.value {
            day.value = currentDay
        }
    }
}
