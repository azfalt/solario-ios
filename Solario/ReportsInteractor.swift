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

    static let lastMonthReport =
        Report(url: URL(string: "http://www-app3.gfz-potsdam.de/kp_index/pqlyymm.tab")!,
               parser: MonthFactParser(),
               title: "_report_title_last_month_fact".localized,
               priority: .high)

    static let currentMonthReport =
        Report(url: URL(string: "http://www-app3.gfz-potsdam.de/kp_index/qlyymm.tab")!,
               parser: MonthFactParser(),
               title: "_report_title_current_month_fact".localized,
               priority: .high)

    static let threeDayForecastReport =
        Report(url: URL(string: "http://services.swpc.noaa.gov/text/3-day-forecast.txt")!,
               parser: ThreeDayForecastParser(),
               title: "_report_title_three_day_forecast".localized,
               priority: .normal)

    static let twentySevenDayForecastReport =
        Report(url: URL(string: "http://services.swpc.noaa.gov/text/27-day-outlook.txt")!,
               parser: TwentySevenDayForecastParser(),
               title: "_report_title_twenty_seven_day_forecast".localized,
               priority: .low)

    struct Notifications {
        
        static let ReportWillStartLoading = Notification.Name("ReportsNotification.ReportWillStartLoading")
        
        static let ReportDidFinishLoading = Notification.Name("ReportsNotification.ReportDidFinishLoading")

        static let AllReportsDidFinishLoading = Notification.Name("ReportsNotification.AllReportsDidFinishLoading")
    }
    
    private lazy var rawDataStorage = RawDataStorage()

    private lazy var rawDataRetriever = RawDataRetriever()

    lazy var reports: [Report] = [
        ReportsInteractor.lastMonthReport,
        ReportsInteractor.currentMonthReport,
        ReportsInteractor.threeDayForecastReport,
        ReportsInteractor.twentySevenDayForecastReport
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
            load(report: report, completion: { [weak self] in
                NotificationCenter.default.post(name: Notifications.ReportDidFinishLoading, object: report)
                if self?.isAnyReportLoading == false {
                    self?.calculateMaxValues()
                    NotificationCenter.default.post(name: Notifications.AllReportsDidFinishLoading, object: nil)
                    completion?()
                }
            })
        }
    }

    private func tryLoadStoredReports() {
        var isLoaded = false
        for report in reports {
            tryLoadStored(report: report)
            isLoaded = isLoaded || report.isLoaded
        }
        if isLoaded {
            calculateMaxValues()
        }
    }

    func load(report: Report, completion: (() -> Void)? = nil) {
        report.isLoading = true
        rawDataRetriever.retrieveRawDataFile(url: report.url, completion: { [weak self] rawDataFile in
            guard
                let self = self,
                let file = rawDataFile else {
                    return
            }
            report.rawDataFile = file
            report.isLoading = false
            self.rawDataStorage.set(rawDataFile: file, url: report.url)
            completion?()
        })
    }

    private func tryLoadStored(report: Report) {
        if let file = rawDataStorage.rawDataFile(url: report.url) {
            report.rawDataFile = file
        }
    }

    init() {
        tryLoadStoredReports()
        subscribeToAppNotifications()
    }
    
    private let calendar = Calendar.current

    private lazy var reportsOrderedByPriority: [Report] = {
        return reports.sorted(by: { $0.priority.rawValue > $1.priority.rawValue })
    }()

    private func subscribeToAppNotifications() {
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
