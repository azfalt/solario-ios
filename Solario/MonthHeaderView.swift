//
//  MonthHeaderView.swift
//  Solario
//
//  Created by Hermann W. on 03.11.19.
//  Copyright © 2019 Hermann Wagenleitner. All rights reserved.
//

import UIKit
import JTAppleCalendar

class MonthHeaderView: JTACMonthReusableView {

    lazy var monthLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    private lazy var weekdaysStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.configure()
    }

    private func configure() {
        addSubview(monthLabel)
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        monthLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        monthLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        monthLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        var calendar = Calendar.current
        calendar.locale = Locale.autoupdatingCurrent
        let shiftIndex = calendar.firstWeekday - 1
        let weekdays = shifted(array: calendar.shortStandaloneWeekdaySymbols, index: shiftIndex)
        addSubview(weekdaysStackView)
        weekdaysStackView.translatesAutoresizingMaskIntoConstraints = false
        weekdaysStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        weekdaysStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        weekdaysStackView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor).isActive = true
        weekdaysStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        for weekday in weekdays {
            let weekdayLabel = UILabel()
            weekdayLabel.textAlignment = .center
            weekdayLabel.text = weekday as? String
            weekdaysStackView.addArrangedSubview(weekdayLabel)
        }
    }

    private func shifted(array: Array<Any>, index: Int) -> Array<Any> {
        var newArr = array[index..<array.count]
        newArr += array[..<index]
        return Array(newArr)
    }
}
