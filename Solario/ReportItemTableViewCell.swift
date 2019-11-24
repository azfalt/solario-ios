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

    private func configure() {
        selectionStyle = .none
    }
}

extension ReportItemTableViewCell {

    func configure(item: DataItem?) {
        if let item = item {
            guard let beginDate = item.dateComponents.beginUTCDate,
                let endDate = item.dateComponents.endUTCDate else {
                    return
            }
            let beginDateString = dateFormatter.string(from: beginDate)
            let endDateString = dateFormatter.string(from: endDate)
            var title = "\(beginDateString)..\(endDateString)"
            
            if item.isForecast {
                title = "\(title), \("_forecast".localized)"
            }
            if item.dateComponents.isCurrent {
                title = "\(title), \("_current".localized)"
            }
            if item.dateComponents.eighth == nil {
                title = "\(title), \("_day_max".localized)"
            }
            textLabel?.text = title
            detailTextLabel?.text = valueFormatter.string(from: NSNumber(value: item.value))
            detailTextLabel?.textColor = Appearance.color(value: item.value)
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
