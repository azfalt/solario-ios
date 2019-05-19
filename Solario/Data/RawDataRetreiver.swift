//
//  RawDataRetreiver.swift
//  Solario
//
//  Created by Hermann Wagenleitner on 13/06/2017.
//  Copyright © 2017 Hermann Wagenleitner. All rights reserved.
//

import Foundation

class RawDataRetreiver {

    func retreiveLastMonthFactRawDataFile(completion: @escaping (RawDataFile?) -> Void) {
        let url = URL(string: "http://www-app3.gfz-potsdam.de/kp_index/pqlyymm.tab")!
        retreiveRawDataFile(url: url, completion: completion)
    }

    func retreiveCurrentMonthFactRawDataFile(completion: @escaping (RawDataFile?) -> Void) {
        let url = URL(string: "http://www-app3.gfz-potsdam.de/kp_index/qlyymm.tab")!
        retreiveRawDataFile(url: url, completion: completion)
    }

    func retreiveThreeDayForecastRawDataFile(completion: @escaping (RawDataFile?) -> Void) {
        let url = URL(string: "http://services.swpc.noaa.gov/text/3-day-forecast.txt")!
        retreiveRawDataFile(url: url, completion: completion)
    }

    func retreiveTwentySevenDayForecastRawDataFile(completion: @escaping (RawDataFile?) -> Void) {
        let url = URL(string: "http://services.swpc.noaa.gov/text/27-day-outlook.txt")!
        retreiveRawDataFile(url: url, completion: completion)
    }

    func retreiveRawDataFile(url: URL, completion: @escaping (RawDataFile?) -> Void) {
        retreiveRawData(url: url, completion: { rawData in
            var rawDataFile: RawDataFile?
            if let rawData = rawData  {
                rawDataFile = RawDataFile(text: rawData)
            }
            completion(rawDataFile)
        })
    }

    private func retreiveRawData(url: URL, completion: @escaping (String?) -> Void) {

        let sharedSession = URLSession.shared
        let task = sharedSession.downloadTask(with: url, completionHandler: {
            (location: URL?, response: URLResponse?, error: Error?) -> Void in

            guard let location = location else {
                return
            }

            let rawData: String?

            do {
                rawData = try String(contentsOf: location)
            } catch {
                print(error.localizedDescription)
                rawData = nil
            }

            completion(rawData)
        })
        task.resume()
    }
}
