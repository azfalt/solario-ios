//
//  Bundle.swift
//  Solario
//
//  Created by Hermann W. on 17.02.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

import UIKit

extension Bundle {

    var appVersion: String {
        return object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }

    var appIcon: UIImage? {
        guard
            let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
            let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
            let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
            let lastIcon = iconFiles.last else {
                return nil
        }
        return UIImage(named: lastIcon)
    }
}
