//
//  SnapshotDummyInteractor.swift
//  Solario
//
//  Created by Aleksandr Pavlov on 09.05.22.
//  Copyright © 2022 Hermann Wagenleitner. All rights reserved.
//

import Foundation

class SnapshotDummyInteractor: DataInteractorProtocol {

    private(set) var isProcessing: Observable<Bool> = Observable(value: false)

    private(set) var dateInterval: DateInterval?

    func maxValue(forDate date: Date) -> Float? {
        return nil
    }

    func items(forDate date: Date) -> [DataItem] {
        var date = date
        var items: [DataItem] = []
        let threeHour: TimeInterval = 3600 * 3
        let values = [1, 2, 3, 4, 6, 5, 4, 3]
        for value in values {
            let dateInterval = DateInterval(start: date, duration: threeHour)
            let item = DataItem(value: Float(value), dateInterval: dateInterval, isForecast: true, priority: .low)
            items.append(item)
            date.addTimeInterval(threeHour)
        }
        return items
    }

    func loadData(completion: LoadCompletion?) {
        completion?(true)
    }
}
