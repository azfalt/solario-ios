//
//  ReportsInteractor.swift
//  Solario
//
//  Created by Hermann Wagenleitner on 10/09/2017.
//  Copyright © 2017 Hermann Wagenleitner. All rights reserved.
//

import Foundation
import UIKit

class ReportsInteractor {
    
    struct Notifications {
        
        static let ReportWillStartLoading = Notification.Name("ReportsNotification.ReportWillStartLoading")
        
        static let ReportDidFinishLoading = Notification.Name("ReportsNotification.ReportDidFinishLoading")

        static let AllReportsDidFinishLoading = Notification.Name("ReportsNotification.AllReportsDidFinishLoading")
    }
    
    let lastMonthReport = LastMonthReport()
    
    let currentMonthReport = CurrentMonthReport()
    
    let threeDayForecastReport = ThreeDayForecastReport()
    
    let twentySevenDayForecastReport = TwentySevenDayForecastReport()
    
    lazy var reports: [Report] = [
        self.lastMonthReport,
        self.currentMonthReport,
        self.threeDayForecastReport,
        self.twentySevenDayForecastReport
    ]

    var isAnyReportLoading: Bool {
        for report in reports {
            if report.isLoading {
                return true
            }
        }
        return false
    }

    var defaultEarliestReportDate: Date {
        let prevMonth = calendar.date(byAdding: .month, value: -1, to: Date())!
        let components = calendar.dateComponents([.year, .month], from: prevMonth)
        let earliest = calendar.date(from: components)!
        return earliest
    }

    var defaultLatestReportDate: Date {
        let latest = calendar.date(byAdding: .day, value: 26, to: Date())!
        return latest
    }

    var earliestReportDate: Date? {
        let prevMonth = calendar.date(byAdding: .month, value: -1, to: Date())!
        let components = calendar.dateComponents([.year, .month], from: prevMonth)
        let earliest = calendar.date(from: components)!
        return earliest
    }

    var reportsDateBounds: DateBounds? {
        var bounds: DateBounds?
        for report in reports {
            if let reportBounds = report.itemsDateBounds {
                if bounds == nil {
                    bounds = reportBounds
                } else {
                    if reportBounds.earliest < bounds!.earliest {
                        bounds!.earliest = reportBounds.earliest
                    }
                    if reportBounds.latest > bounds!.latest {
                        bounds!.latest = reportBounds.latest
                    }
                }
            }
        }
        return bounds
    }

    func maxValue(forDate date: Date) -> Float? {
        return maxValuesByDate[date]
    }

    func mergedItems(forDate date: Date) -> [DataItem] {
        var resultItems: [DataItem] = []
        for report in reportsOrderedByPriority {
            guard let items = report.items else {
                continue
            }
            for item in items {
                guard item.dateComponents.beginDay == date else {
                    continue
                }
                var isAlreadyAdded = false
                for resultItem in resultItems {
                    guard resultItem.dateComponents.hasTheSameBaseDate(as: item.dateComponents) else {
                        continue
                    }
                    if let itemEight = item.dateComponents.eighth {
                        if let resultItemEight = resultItem.dateComponents.eighth,
                            itemEight == resultItemEight {
                            isAlreadyAdded = true
                            break
                        }
                    } else {
                        isAlreadyAdded = true
                        break
                    }
                }
                if !isAlreadyAdded {
                    resultItems.append(item)
                }
            }
        }
        return resultItems
    }

    func loadReports(completion: (() -> Void)? = nil) {
        for report in reports {
            NotificationCenter.default.post(name: Notifications.ReportWillStartLoading, object: report)
            report.load(completion: { [weak self] in
                NotificationCenter.default.post(name: Notifications.ReportDidFinishLoading, object: report)
                if self?.isAnyReportLoading == false {
                    self?.calculateMaxValues()
                    NotificationCenter.default.post(name: Notifications.AllReportsDidFinishLoading, object: nil)
                    completion?()
                }
            })
        }
    }

    init() {
        subsribeToAppNotifications()
    }
    
    private let calendar = Calendar.current

    private lazy var reportsOrderedByPriority: [Report] = {
        return reports.sorted(by: { $0.priority.rawValue > $1.priority.rawValue })
    }()

    private func subsribeToAppNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loadReports),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    @objc private func loadReports() {
        loadReports(completion: nil)
    }

    private var maxValuesByDate = [Date:Float]()

    private func calculateMaxValues() {
        guard let dateBounds = reportsDateBounds else {
            return
        }
        maxValuesByDate.removeAll()
        var date = calendar.startOfDay(for: dateBounds.earliest)
        while date < dateBounds.latest {
            maxValuesByDate[date] = itemWithMaxValue(forDate: date)?.value
            date = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: date)!)
        }
    }

    private func itemWithMaxValue(forDate date: Date) -> DataItem? {
        var resultItem: DataItem?
        let items = mergedItems(forDate: date)
        for item in items {
            if resultItem == nil || item.value > resultItem!.value {
                resultItem = item
            }
        }
        return resultItem
    }
}
