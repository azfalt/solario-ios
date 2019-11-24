//
//  ThreeDayForecastReport.swift
//  Solario
//
//  Created by Hermann Wagenleitner on 03/08/2017.
//  Copyright © 2017 Hermann Wagenleitner. All rights reserved.
//

import Foundation

class ThreeDayForecastReport: Report {

    override func configure() {
        super.configure()
        title = "_report_title_three_day_forecast".localized
        fileURL = URL(string: "http://services.swpc.noaa.gov/text/3-day-forecast.txt")!
        priority = .normal
    }

    override func createParser(rawDataFile: RawDataFile) -> DataFileParser? {
        return ThreeDayForecastParser(rawDataFile: rawDataFile)
    }
}
