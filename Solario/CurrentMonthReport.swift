//
//  CurrentMonthReport.swift
//  Solario
//
//  Created by Hermann Wagenleitner on 03/08/2017.
//  Copyright © 2017 Hermann Wagenleitner. All rights reserved.
//

import Foundation

class CurrentMonthReport: Report {

    override func configure() {
        super.configure()
        title = "_report_title_current_month_fact".localized
        fileURL = URL(string: "http://www-app3.gfz-potsdam.de/kp_index/qlyymm.tab")!
        priority = .high
    }

    override func createParser(rawDataFile: RawDataFile) -> DataFileParser? {
        return MonthFactParser(rawDataFile: rawDataFile)
    }
}
