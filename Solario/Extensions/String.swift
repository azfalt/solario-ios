//
//  String.swift
//  Solario
//
//  Created by Hermann Wagenleitner on 02/08/2017.
//  Copyright © 2017 Hermann Wagenleitner. All rights reserved.
//

import Foundation

extension String {

    var localized: String {
        return Bundle.main.localizedString(forKey: self, value: nil, table: nil)
    }

    var capitalizedFirstLetter: String {
        return prefix(1).capitalized + dropFirst()
    }
}
