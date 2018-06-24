//
//  ReportsInteractor.swift
//  Solario
//
//  Created by Herman Wagenleitner on 10/09/2017.
//  Copyright © 2017 Herman Wagenleitner. All rights reserved.
//

import Foundation

class ReportsInteractor {

  struct Notifications {

    static let ReportWillStartLoading = Notification.Name("ReportsNotification.ReportWillStartLoading")

    static let ReportDidFinishLoading = Notification.Name("ReportsNotification.ReportDidFinishLoading")
  }

  public let lastMonthReport = LastMonthReport()

  public let currentMonthReport = CurrentMonthReport()

  public let threeDayForecastReport = ThreeDayForecastReport()

  public let twentySevenDayForecastReport = TwentySevenDayForecastReport()

  public lazy var reports: [Report] = [
    self.lastMonthReport,
    self.currentMonthReport,
    self.threeDayForecastReport,
    self.twentySevenDayForecastReport
  ]

  public var isAnyReportLoading: Bool {
    for report in reports {
      if report.isLoading {
        return true
      }
    }
    return false
  }

  init() {
    subsribeToAppNotifications()
  }

  private func subsribeToAppNotifications() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(loadReports),
                                           name: Notification.Name.UIApplicationDidBecomeActive,
                                           object: nil)
  }

  dynamic private func loadReports() {
    loadReports(completion: nil)
  }

  public func loadReports(completion: (() -> Void)? = nil) {
    for report in reports {
      NotificationCenter.default.post(name: Notifications.ReportWillStartLoading, object: report)
      report.load(completion: { [weak self] in
        NotificationCenter.default.post(name: Notifications.ReportDidFinishLoading, object: report)
        if self?.isAnyReportLoading == false {
          completion?()
        }
      })
    }
  }
}
