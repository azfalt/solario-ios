//
//  DataProcessor.swift
//  Solario
//
//  Created by Hermann W. on 19.02.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

import Foundation

class DataProcessor: DataProcessorProtocol {

    private let calendar: Calendar = Constants.calendar

    // MARK: - DataProcessorProtocol

    func prepare(items: [DataItem]) -> [Date:[DataItem]] {
        let splitItems = splitByDays(items: items)
        let mergedItems = mergeUsingPriority(items: splitItems)
        return groupByDays(items: mergedItems)
    }

    func calculateMaxValues(itemsByDate: [Date:[DataItem]]) -> [Date:Float] {
        var maxValuesByDate = [Date:Float]()
        maxValuesByDate.removeAll()
        for (day, items) in itemsByDate {
            for item in items {
                if maxValuesByDate[day] == nil || item.value > maxValuesByDate[day]! {
                    maxValuesByDate[day] = item.value
                }
            }
        }
        return maxValuesByDate
    }

    func dateInterval(dates: [Date]) -> DateInterval? {
        if let min = dates.min(), let max = dates.max() {
            return DateInterval(start: min, end: max)
        }
        return nil
    }

    // MARK: -

    private func splitByDays(items: [DataItem]) -> [DataItem] {
        var resultItems: [DataItem] = []
        for item in items {
            let startDate = item.dateInterval.start
            let endDate = item.dateInterval.end
            if calendar.isDate(startDate, inSameDayAs: endDate) {
                resultItems.append(item)
            } else {
                let splitResult = splitByDays(item: item)
                resultItems.append(contentsOf: splitResult)
            }
        }
        return resultItems
    }

    private func splitByDays(item: DataItem) -> [DataItem] {
        let beginDate = item.dateInterval.start
        let endDate = item.dateInterval.end
        let splitDate = calendar.startOfDay(for: endDate)
        let interval1 = DateInterval(start: beginDate, end: splitDate)
        let item1 = DataItem(value: item.value, dateInterval: interval1, isForecast: item.isForecast, priority: item.priority)
        let interval2 = DateInterval(start: splitDate, end: endDate)
        let item2 = DataItem(value: item.value, dateInterval: interval2, isForecast: item.isForecast, priority: item.priority)
        return [item1, item2]
    }

    private func mergeUsingPriority(items: [DataItem]) -> [DataItem] {
        let prioritisedItems = items.sorted(by: { $0.priority.rawValue > $1.priority.rawValue })
        var resultItems: [DataItem] = []
        for item in prioritisedItems {
            var isAlreadyAdded = false
            for resultItem in resultItems {
                if let intersection = resultItem.dateInterval.intersection(with: item.dateInterval) {
                    if intersection.duration > 0 {
                        isAlreadyAdded = true
                        break
                    }
                }
            }
            if !isAlreadyAdded {
                resultItems.append(item)
            }
        }
        return resultItems
    }

    private func groupByDays(items: [DataItem]) -> [Date:[DataItem]] {
        var itemsByDate = [Date:[DataItem]]()
        for item in items {
            let day = calendar.startOfDay(for: item.dateInterval.start)
            if itemsByDate[day] == nil {
                itemsByDate[day] = []
            }
            itemsByDate[day]!.append(item)
        }
        return itemsByDate
    }
}
