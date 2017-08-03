//
//  ThreeDayForecastReport.swift
//  Solario
//
//  Created by Herman Wagenleitner on 03/08/2017.
//  Copyright © 2017 Herman Wagenleitner. All rights reserved.
//

import Foundation

class ThreeDayForecastReport: Report {

    override func configure() {
        super.configure()
        title = "_report_title_three_day_forecast".localized
        fileURL = URL(string: "http://services.swpc.noaa.gov/text/3-day-forecast.txt")!
    }

    override func createParser(rawDataFile: RawDataFile) -> DataFileParser? {
        return ThreeDayForecastParser(rawDataFile: rawDataFile)
    }
}
