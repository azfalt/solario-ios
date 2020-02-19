//
//  Bundle.swift
//  Solario
//
//  Created by Hermann W. on 17.02.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

import Foundation

extension Bundle {

    var appVersion: String {
        return object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }
}
