//
//  ReportsInteractor.swift
//  Solario
//
//  Created by Hermann Wagenleitner on 10/09/2017.
//  Copyright © 2017 Hermann Wagenleitner. All rights reserved.
//

import Foundation
import UIKit

class ReportsInteractor: DependencyProtocol {

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

    private(set) lazy var reports: [Report] = [
        ReportsInteractor.lastMonthReport,
        ReportsInteractor.currentMonthReport,
        ReportsInteractor.threeDayForecastReport,
        ReportsInteractor.twentySevenDayForecastReport
    ]

    private(set) var isUpdating: Observable<Bool> = Observable(value: false)

    private func updateUpdatingState() {
        isUpdating.value = isLoading || isCalculating
    }

    private var isCalculating: Bool = false {
        didSet {
            updateUpdatingState()
        }
    }

    private var isLoading: Bool = false {
        didSet {
            updateUpdatingState()
        }
    }

    private var isAnyReportLoading: Bool {
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

    var reportsDateInterval: DateInterval? {
        var interval: DateInterval?
        for report in reports {
            if let reportInterval = report.itemsDateInterval {
                if interval == nil {
                    interval = reportInterval
                } else {
                    if reportInterval.start < interval!.start {
                        interval!.start = reportInterval.start
                    }
                    if reportInterval.end > interval!.end {
                        interval!.end = reportInterval.end
                    }
                }
            }
        }
        return interval
    }

    func maxValue(forDate date: Date) -> Float? {
        return maxValuesByDate[date]
    }

    func mergedItems(forDate date: Date) -> [DataItem] {
        var resultItems: [DataItem] = []
        for report in reportsOrderedByPriority {
            guard let reportItems = report.items else {
                continue
            }
            let items = splitByDays(items: reportItems)
            for item in items {
                let itemDay = calendar.startOfDay(for: item.dateInterval.start)
                guard itemDay == date else {
                    continue
                }
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
        }
        return resultItems
    }

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
        let item1 = DataItem(value: item.value, dateInterval: interval1, isForecast: item.isForecast)
        let interval2 = DateInterval(start: splitDate, end: endDate)
        let item2 = DataItem(value: item.value, dateInterval: interval2, isForecast: item.isForecast)
        return [item1, item2]
    }

    func loadReports(completion: (() -> Void)? = nil) {
        for report in reports {
            isLoading = true
            load(report: report, completion: { [weak self] in
                defer {
                    completion?()
                }
                guard let self = self else {
                    return
                }
                if self.isAnyReportLoading == false {
                    self.calculateMaxValues()
                    self.isLoading = false
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
            defer {
                completion?()
            }
            report.isLoading = false
            guard
                let self = self,
                let file = rawDataFile else {
                    return
            }
            report.rawDataFile = file
            self.rawDataStorage.set(rawDataFile: file, url: report.url)
        })
    }

    private func tryLoadStored(report: Report) {
        if let file = rawDataStorage.rawDataFile(url: report.url) {
            report.rawDataFile = file
        }
    }

    init() {
        tryLoadStoredReports()
        addObservers()
    }

    deinit {
        removeObservers()
    }
    
    private let calendar = Calendar.current

    private lazy var reportsOrderedByPriority: [Report] = {
        return reports.sorted(by: { $0.priority.rawValue > $1.priority.rawValue })
    }()

    private func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loadReports),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        timeService.day.addObserver(self) { [weak self] day in
            self?.loadReports()
        }
    }

    private func removeObservers() {
        timeService.day.removeObserver(self)
    }

    @objc private func loadReports() {
        loadReports(completion: nil)
    }

    private var maxValuesByDate = [Date:Float]()

    private func calculateMaxValues() {
        guard let dateInterval = reportsDateInterval else {
            return
        }
        isCalculating = true
        maxValuesByDate.removeAll()
        var date = calendar.startOfDay(for: dateInterval.start)
        while date < dateInterval.end {
            maxValuesByDate[date] = itemWithMaxValue(forDate: date)?.value
            date = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: date)!)
        }
        isCalculating = false
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
