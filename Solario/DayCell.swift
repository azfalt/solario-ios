//
//  DayCell.swift
//  Solario
//
//  Created by Hermann W. on 01.11.19.
//  Copyright © 2019 Hermann Wagenleitner. All rights reserved.
//

import UIKit
import JTAppleCalendar

class DayCell: JTACDayCell {

    private lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.clipsToBounds = true
        return label
    }()

    private lazy var selectView: UIView = {
        let view = UIView()
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(state: CellState, value: Float?) {

        label.alpha = state.dateBelongsTo == .thisMonth ? 1 : 0.3;
        label.text = state.text

        if (state.isSelected) {
            selectView.layer.borderColor = UIColor.label.cgColor
            selectView.isHidden = false
        } else {
            selectView.isHidden = true
        }

        if let value = value {
            label.textColor = UIColor.white
            label.backgroundColor = Appearance.color(value: value)
        } else {
            label.textColor = UIColor.label
            label.backgroundColor = UIColor.clear
        }
    }

    private func configure() {

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
        label.layer.cornerRadius = labelSideLength / 2;
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: labelSideLength).isActive = true
        label.heightAnchor.constraint(equalToConstant: labelSideLength).isActive = true
        label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    }
}
