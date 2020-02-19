//
//  ReportItemTableViewCell.swift
//  Solario
//
//  Created by Hermann Wagenleitner on 03/08/2017.
//  Copyright © 2017 Hermann Wagenleitner. All rights reserved.
//

import UIKit

class ReportItemTableViewCell: UITableViewCell, DependencyProtocol {

    init() {
        super.init(style: UITableViewCell.CellStyle.value1, reuseIdentifier: String(describing: Self.self))
        configure()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.value1, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    private lazy var fontSize: CGFloat = {
        return textLabel?.font.pointSize ?? UIFont.labelFontSize
    }()

    private func configure() {
        selectionStyle = .none
        textLabel?.adjustsFontSizeToFitWidth = true
        detailTextLabel?.adjustsFontSizeToFitWidth = true
        textLabel?.numberOfLines = 0
    }

    func configure(item: DataItem?) {
        if let item = item {
            let startDate = item.dateInterval.start
            let endDate = item.dateInterval.end
            let beginDateString = dateFormatter.string(from: startDate)
            let endDateString = dateFormatter.string(from: endDate)
            var title = String(format: Constants.dateIntervalWithPlaceholders, beginDateString, endDateString)
            var titleFontWeight: UIFont.Weight = .regular
            var valueFontWeight: UIFont.Weight = .medium
            var valueFontSize = fontSize;
            if item.isForecast {
                title = "\(title), \(Constants.forecast)"
            }
            if item.isCurrent {
                title = "\(title), \(Constants.current)"
                titleFontWeight = .semibold
                valueFontWeight = .bold
                valueFontSize *= 1.1
            }
            textLabel?.text = title
            textLabel?.font = .monospacedDigitSystemFont(ofSize: fontSize, weight: titleFontWeight)
            detailTextLabel?.text = valueFormatter.string(from: NSNumber(value: item.value))
            detailTextLabel?.textColor = appearance.color(forValue: item.value)
            detailTextLabel?.font = .monospacedDigitSystemFont(ofSize: valueFontSize, weight: valueFontWeight)
        } else {
            textLabel?.text = "—"
            detailTextLabel?.text = nil
        }
    }

    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .none
        df.timeStyle = .short
        return df
    }

    private var valueFormatter: NumberFormatter {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = 1
        nf.maximumFractionDigits = 1
        return nf
    }
}
