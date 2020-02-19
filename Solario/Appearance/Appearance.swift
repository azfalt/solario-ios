//
//  Appearance.swift
//  Solario
//
//  Created by Hermann Wagenleitner on 30.09.18.
//  Copyright © 2018 Hermann Wagenleitner. All rights reserved.
//

struct Appearance: AppearanceProtocol {

    let tintColor = UIColor(red:0.99, green:0.38, blue:0.25, alpha:1.00)

    func color(forValue value: Float) -> UIColor {
        switch value {
        case 0...1:
            return UIColor(red:0.16, green:0.78, blue:0.14, alpha:1.00)
        case 1...2:
            return UIColor(red:0.38, green:0.85, blue:0.15, alpha:1.00)
        case 2...3:
            return UIColor(red:0.70, green:0.85, blue:0.17, alpha:1.00)
        case 3...4:
            return UIColor(red:0.91, green:0.79, blue:0.18, alpha:1.00)
        case 4...5:
            return UIColor(red:0.94, green:0.44, blue:0.13, alpha:1.00)
        case 5...6:
            return UIColor(red:0.94, green:0.11, blue:0.10, alpha:1.00)
        case 6...7:
            return UIColor(red:0.88, green:0.04, blue:0.13, alpha:1.00)
        case 7...8:
            return UIColor(red:0.75, green:0.04, blue:0.30, alpha:1.00)
        case 8...9:
            return UIColor(red:0.67, green:0.05, blue:0.42, alpha:1.00)
        case 9...:
            return UIColor(red:0.59, green:0.07, blue:0.53, alpha:1.00)
        default:
            return .clear
        }
    }
}
