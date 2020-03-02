//
//  ReportFactory.swift
//  Solario
//
//  Created by Hermann W. on 19.02.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

import Foundation

class ReportFactory: ReportFactoryProtocol {

    func createReports() -> [ReportProtocol] {
        return [
            Report(url: Constants.gfzLastMonthReportURL, parser: GFZMonthFactParser(), priority: .high),
            Report(url: Constants.gfzCurrentMonthReportURL, parser: GFZMonthFactParser(), priority: .high),
            Report(url: Constants.noaa3DayForecastReportURL, parser: NOAA3DayForecastParser(), priority: .normal),
            Report(url: Constants.noaa27DayOutlookReportURL, parser: NOAA27DayOutlookParser(), priority: .low),
        ]
    }
}
