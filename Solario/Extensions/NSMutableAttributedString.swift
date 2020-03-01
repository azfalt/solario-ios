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

    func set(image: UIImage, forText text: String, capHeight: CGFloat? = nil) {
        let range = mutableString.range(of: text)
        let attachment = NSTextAttachment(image: image)
        if let capHeight = capHeight {
            let imageY = ((capHeight - image.size.height) / 2).roundedToPixel
            attachment.bounds = CGRect(x: 0, y: imageY, width: image.size.width, height: image.size.height)
        }
        replaceCharacters(in: range, with: NSAttributedString(attachment: attachment))
    }
}
