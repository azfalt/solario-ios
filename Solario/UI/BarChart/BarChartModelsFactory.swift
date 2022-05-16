//
//  BarChartModelsFactory.swift
//  Solario
//
//  Created by Aleksandr Pavlov on 09.05.22.
//  Copyright © 2022 Hermann Wagenleitner. All rights reserved.
//

import UIKit

class BarChartModelsFactory: BarChartModelsFactoryProtocol {

    private let appearance = Appearance()

    func models(with items: [DataItem], allowSeparator: Bool) -> [BarChartItemModel] {

        var models: [BarChartItemModel] = []
        let dayFormatter = self.dayFormatter
        let hourFormatter = self.hourFormatter
        let valueFormatter = self.valueFormatter
        let appearance = Appearance()
        let calendar = Constants.calendar
        var lastDate: Date?
        let maxValue: Float = 9
        let minValueToShowTitle: Float = 3
        let itemsNumberMinForDayTitle = 3
        let heightMin = 0.02

        for index in 0...items.count-1 {

            let item = items[index]

            var isNewDay = false
            if let lastDate = lastDate {
                if !calendar.isDate(lastDate, inSameDayAs: item.dateInterval.start) {
                    isNewDay = true
                }
            } else {
                isNewDay = true
            }
            lastDate = item.dateInterval.start

            let showSeparator = isNewDay ? allowSeparator : false

            var dayTitle = ""
            if isNewDay {
                let rest = items.count - index
                if rest >= itemsNumberMinForDayTitle {
                    dayTitle = dayFormatter.string(from: item.dateInterval.start)
                }
            }

            var valueTitle = ""
            if item.value >= minValueToShowTitle {
                valueTitle = valueFormatter.string(from: NSNumber(value: item.value))!
            }

            var heightRatio = CGFloat(item.value / maxValue)
            if heightRatio < heightMin {
                heightRatio = heightMin
            }

            let model = BarChartItemModel(dayTitle: dayTitle,
                                          timeTitle: hourFormatter.string(from: item.dateInterval.start),
                                          valueTitle: valueTitle,
                                          color: appearance.color(forValue: item.value),
                                          heightRatio: heightRatio,
                                          showSeparator: showSeparator)
            models.append(model)
        }

        return models
    }

    private var valueFormatter: NumberFormatter {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 1
        return nf
    }

    private var hourFormatter: DateFormatter {
        let df = DateFormatter()
        if Locale.is24HourFormat {
            df.dateFormat = "HH"
        } else {
            df.dateFormat = "ha"
        }
        return df
    }

    private var dayFormatter: DateFormatter {
        let df = DateFormatter()
        df.timeStyle = .none
        df.dateStyle = .medium
        return df
    }
}

