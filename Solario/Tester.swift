//
//  Tester.swift
//  Solario
//
//  Created by Herman Wagenleitner on 03/08/2017.
//  Copyright © 2017 Herman Wagenleitner. All rights reserved.
//

import Foundation

class Tester {

    func test() {

        print("start test...")

        let retreiver = RawDataRetreiver()

        retreiver.retreiveLastMonthFactRawDataFile(completion: { rawDataFile in
            print("LAST MONTH FACT -----------------------------")
            //      print("\(rawDataFile?.lines)")
            guard let rawDataFile = rawDataFile else {
                return
            }
            let parser = MonthFactParser(rawDataFile: rawDataFile)
            guard let items = try? parser.items() else {
                print("ERROR!")
                return
            }
            print("items = \(items)")
        })

        retreiver.retreiveCurrentMonthFactRawDataFile(completion: { rawDataFile in
            print("CURRENT MONTH FACT -----------------------------")
            //      print("\(rawDataFile?.lines)")
            guard let rawDataFile = rawDataFile else {
                return
            }
            let parser = MonthFactParser(rawDataFile: rawDataFile)
            guard let items = try? parser.items() else {
                return
            }
            print("items = \(items)")
        })


        retreiver.retreiveThreeDayForecastRawDataFile(completion: { rawDataFile in
            print("03DFC -----------------------------")
            //      print("\(rawDataFile?.lines)")
            guard let rawDataFile = rawDataFile else {
                return
            }
            let parser = ThreeDayForecastParser(rawDataFile: rawDataFile)
            let issueDate = parser.issueDate
            print("issueDate = \(String(describing: issueDate))")
            guard let items = try? parser.items() else {
                return
            }
            print("items = \(items)")
        })

        retreiver.retreiveTwentySevenDayForecastRawDataFile(completion: { rawDataFile in
            print("27DFC -----------------------------")
            //      print("\(rawDataFile?.lines)")
            guard let rawDataFile = rawDataFile else {
                return
            }
            let parser = TwentySevenDayForecastParser(rawDataFile: rawDataFile)
            let issueDate = parser.issueDate
            print("issueDate = \(String(describing: issueDate))")
            guard let items = try? parser.items() else {
                return
            }
            print("items = \(items)")
        })
    }
}
