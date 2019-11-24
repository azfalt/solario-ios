//
//  TwentySevenDayForecastReport.swift
//  Solario
//
//  Created by Hermann Wagenleitner on 03/08/2017.
//  Copyright © 2017 Hermann Wagenleitner. All rights reserved.
//

import Foundation

class TwentySevenDayForecastReport: Report {

    override func configure() {
        super.configure()
        title = "_report_title_twenty_seven_day_forecast".localized
        fileURL = URL(string: "http://services.swpc.noaa.gov/text/27-day-outlook.txt")!
        priority = .low
    }

    override func createParser(rawDataFile: RawDataFile) -> DataFileParser? {
        return TwentySevenDayForecastParser(rawDataFile: rawDataFile)
    }
}
