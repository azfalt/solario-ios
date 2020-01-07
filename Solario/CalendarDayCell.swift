//
//  CalendarDayCell.swift
//  Solario
//
//  Created by Hermann W. on 29.11.19.
//  Copyright © 2019 Hermann Wagenleitner. All rights reserved.
//

import UIKit

class CalendarDayCell: FSCalendarCell {

    private lazy var selectView = UIView()

    private var value: Float?

    private lazy var normalFont: UIFont = {
        return UIFont.preferredFont(forTextStyle: .body)
    }()

    private lazy var todayFont: UIFont = {
        return UIFont.systemFont(ofSize: normalFont.pointSize, weight: .heavy)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func performSelecting() {
        updateSeletedViewState()
    }

    override func configureAppearance() {
        updateSeletedViewState()
        if let value = value {
            titleLabel.textColor = UIColor.systemBackground
            let color = Appearance.color(value: value)
            titleLabel.backgroundColor = color
        } else {
            titleLabel.textColor = UIColor.label
            titleLabel.backgroundColor = UIColor.clear
        }
        titleLabel.alpha = isPlaceholder ? 0.3 : 1
        titleLabel.font = self.dateIsToday ? todayFont : normalFont
        selectView.layer.borderColor = UIColor.label.cgColor
    }

    func configure(position: FSCalendarMonthPosition, value: Float?) {
        self.value = value
        configureAppearance()
    }

    private func configure() {

        shapeLayer.isHidden = true

        let contentSideLength = min(frame.size.width, frame.size.height)
        selectView.layer.cornerRadius = contentSideLength / 2
        selectView.layer.borderWidth = contentSideLength * 0.06
        contentView.addSubview(selectView)
        selectView.translatesAutoresizingMaskIntoConstraints = false
        selectView.widthAnchor.constraint(equalToConstant: contentSideLength).isActive = true
        selectView.heightAnchor.constraint(equalToConstant: contentSideLength).isActive = true
        selectView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        selectView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true

        let labelSideLength = contentSideLength * 0.8
        titleLabel.clipsToBounds = true
        titleLabel.layer.cornerRadius = labelSideLength / 2;
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.widthAnchor.constraint(equalToConstant: labelSideLength).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: labelSideLength).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    }

    private func updateSeletedViewState() {
        selectView.isHidden = !isSelected
    }
}
