//
//  Constants.swift
//  Solario
//
//  Created by Hermann W. on 16.02.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

struct Constants {

    static let appName = "Solario"

    static let gfzLastMonthReportURL = URL(string: "http://www-app3.gfz-potsdam.de/kp_index/pqlyymm.tab")!
    static let gfzCurrentMonthReportURL = URL(string: "http://www-app3.gfz-potsdam.de/kp_index/qlyymm.tab")!
    static let noaa3DayForecastReportURL = URL(string: "https://services.swpc.noaa.gov/text/3-day-forecast.txt")!
    static let noaa27DayOutlookReportURL = URL(string: "https://services.swpc.noaa.gov/text/27-day-outlook.txt")!

    static let forecast = "_forecast".localized
    static let current = "_current".localized
    static let dateIntervalWithPlaceholders = "_date_interval_wp".localized
    static let noData = "_no_data".localized
    static let appVersionWithPlaceholder = "_app_version_wp".localized
    static let appDescrWithPlaceholders = "_app_descr_wp".localized
    static let kp = "_kp".localized
    static let noaaTitle = "_noaa_title".localized
    static let noaaURL = URL(string: "_noaa_url".localized)!
    static let gfzTitle = "_gfz_title".localized
    static let gfzURL = URL(string: "_gfz_url".localized)!
    static let ccBy40Title = "_cc_by_40_title".localized
    static let ccBy40URL = URL(string: "_cc_by_40_url".localized)!
    static let openSource = "_open_source".localized

    static let imagePlaceholder = "[IMAGE]"
    static let gitHubMarkImage = UIImage(named: "github-mark") ?? UIImage()
    static let gitHubURL = URL(string: "https://github.com/azfalt/solario-ios")!

    static let calendar = Calendar.current
}
