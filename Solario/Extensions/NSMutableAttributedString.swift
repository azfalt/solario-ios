//
//  NSMutableAttributedString.swift
//  Solario
//
//  Created by Hermann W. on 16.02.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

import Foundation

extension NSMutableAttributedString {

    func set(url: URL, forText text: String) {
        let range = mutableString.range(of: text)
        addAttribute(.link, value: url, range: range)
    }

    func set(font: UIFont, forText text: String) {
        let range = mutableString.range(of: text)
        addAttribute(.font, value: font, range: range)
    }
}
