//
//  AppearanceProtocol.swift
//  Solario
//
//  Created by Hermann W. on 16.02.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

protocol AppearanceProtocol {

    var tintColor: UIColor { get }

    func color(forValue value: Float) -> UIColor
}
