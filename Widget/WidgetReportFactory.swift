//
//  WidgetReportFactory.swift
//  Solario
//
//  Created by Aleksandr Pavlov on 09.05.22.
//  Copyright © 2022 Hermann Wagenleitner. All rights reserved.
//

import Foundation

class WidgetReportFactory: ReportFactoryProtocol {

    func createReports() -> [ReportProtocol] {
        return [
            Report(url: Constants.gfzCurrentMonthReportURL, parser: GFZMonthFactParser(), priority: .high),
            Report(url: Constants.noaa3DayForecastReportURL, parser: NOAA3DayForecastParser(), priority: .normal),
        ]
    }
}

