//
//  ReportItemTableViewCell.swift
//  Solario
//
//  Created by Hermann Wagenleitner on 03/08/2017.
//  Copyright © 2017 Hermann Wagenleitner. All rights reserved.
//

import UIKit

class ReportItemTableViewCell: UITableViewCell {

    init() {
        super.init(style: UITableViewCell.CellStyle.value1, reuseIdentifier: String(describing: ReportItemTableViewCell.self))
        configure()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.value1, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
}

extension ReportItemTableViewCell {

    func configure(item: DataItem?) {
        if let item = item {
            let startDate = item.dateInterval.start
            let endDate = item.dateInterval.end
            let beginDateString = dateFormatter.string(from: startDate)
            let endDateString = dateFormatter.string(from: endDate)
            var title = "\(beginDateString)..\(endDateString)"
            var titleFontWeight: UIFont.Weight = .regular
            var valueFontWeight: UIFont.Weight = .medium
            var valueFontSize = fontSize;
            if item.isForecast {
                title = "\(title), \("_forecast".localized)"
            }
            if item.isCurrent {
                title = "\(title), \("_current".localized)"
                titleFontWeight = .semibold
                valueFontWeight = .bold
                valueFontSize *= 1.1
            }
            textLabel?.text = title
            textLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: titleFontWeight)
            detailTextLabel?.text = valueFormatter.string(from: NSNumber(value: item.value))
            detailTextLabel?.textColor = Appearance.color(value: item.value)
            detailTextLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: valueFontSize, weight: valueFontWeight)
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
        let vf = NumberFormatter()
        vf.numberStyle = .decimal
        vf.minimumFractionDigits = 1
        vf.maximumFractionDigits = 1
        return vf
    }
}
