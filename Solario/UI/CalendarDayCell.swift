//
//  CalendarDayCell.swift
//  Solario
//
//  Created by Hermann W. on 29.11.19.
//  Copyright © 2019 Hermann Wagenleitner. All rights reserved.
//

import UIKit

class CalendarDayCell: FSCalendarCell, DependencyProtocol {

    private lazy var selectView = UIView()

    private var value: Float?

    private lazy var normalFont: UIFont = {
        return .preferredFont(forTextStyle: .body)
    }()

    private lazy var todayFont: UIFont = {
        return .systemFont(ofSize: normalFont.pointSize, weight: .heavy)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    override func performSelecting() {
        updateSelectViewState()
    }

    override func configureAppearance() {
        updateSelectViewState()
        if let value = value {
            titleLabel.textColor = .systemBackground
            titleLabel.backgroundColor = appearance.color(forValue: value)
        } else {
            titleLabel.textColor = .label
            titleLabel.backgroundColor = .clear
        }
        titleLabel.alpha = isPlaceholder ? 0.3 : 1
        titleLabel.font = dateIsToday ? todayFont : normalFont
        selectView.layer.borderColor = UIColor.label.cgColor
    }

    func configure(position: FSCalendarMonthPosition, value: Float?) {
        self.value = value
        configureAppearance()
    }

    private func configure() {

        shapeLayer.isHidden = true

        let contentSideLength = min(frame.size.width, frame.size.height)

        let labelSideLength = round(contentSideLength * 0.8)
        titleLabel.clipsToBounds = true
        titleLabel.layer.cornerRadius = labelSideLength / 2;
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.baselineAdjustment = .alignCenters
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.widthAnchor.constraint(equalToConstant: labelSideLength).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: labelSideLength).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true

        let selectPadding = ((contentSideLength - labelSideLength) / 2).roundedToPixel
        selectView.layer.cornerRadius = (contentSideLength / 2).roundedToPixel
        selectView.layer.borderWidth = (contentSideLength * 0.06).roundedToPixel
        contentView.addSubview(selectView)
        selectView.translatesAutoresizingMaskIntoConstraints = false
        selectView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -selectPadding).isActive = true
        selectView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: selectPadding).isActive = true
        selectView.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -selectPadding).isActive = true
        selectView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: selectPadding).isActive = true
    }

    private func updateSelectViewState() {
        selectView.isHidden = isPlaceholder || !isSelected
    }
}
