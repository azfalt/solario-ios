//
//  Extensions.swift
//  Solario
//
//  Created by Herman Wagenleitner on 02/08/2017.
//  Copyright © 2017 Herman Wagenleitner. All rights reserved.
//

import Foundation

extension String {

    var localized: String {
        return Bundle.main.localizedString(forKey: self, value: nil, table: nil)
    }
}
