//
//  ReportItemTableViewCell.swift
//  Solario
//
//  Created by Herman Wagenleitner on 03/08/2017.
//  Copyright © 2017 Herman Wagenleitner. All rights reserved.
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
        textLabel?.textColor = Appearance.textColor
    }
}

extension ReportItemTableViewCell {

    func configure(item: DataItem?) {
        if let item = item {
            guard let date = item.dateComponents.date else {
                return
            }
            let dateString = dateFormatter.string(from: date)
            textLabel?.text = dateString
            detailTextLabel?.text = valueFormatter.string(from: NSNumber(value: item.value))
            detailTextLabel?.textColor = getColor(value: item.value)
        } else {
            textLabel?.text = "—"
            detailTextLabel?.text = nil
        }
    }

    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .long
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

    private func getColor(value: Float) -> UIColor {
        if value <= 1 {
            return UIColor(red:0.16, green:0.78, blue:0.14, alpha:1.00)
        } else if value <= 2 {
            return UIColor(red:0.38, green:0.85, blue:0.15, alpha:1.00)
        } else if value <= 3 {
            return UIColor(red:0.70, green:0.85, blue:0.17, alpha:1.00)
        } else if value <= 4 {
            return UIColor(red:0.91, green:0.79, blue:0.18, alpha:1.00)
        } else if value <= 5 {
            return UIColor(red:0.94, green:0.44, blue:0.13, alpha:1.00)
        } else if value <= 6 {
            return UIColor(red:0.94, green:0.11, blue:0.10, alpha:1.00)
        } else if value <= 7 {
            return UIColor(red:0.88, green:0.04, blue:0.13, alpha:1.00)
        } else if value <= 8 {
            return UIColor(red:0.75, green:0.04, blue:0.30, alpha:1.00)
        } else if value <= 9 {
            return UIColor(red:0.67, green:0.05, blue:0.42, alpha:1.00)
        } else {
            return UIColor(red:0.59, green:0.07, blue:0.53, alpha:1.00)
        }
    }
}
