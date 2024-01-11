//
//  AppDescrView.swift
//  Solario
//
//  Created by Hermann W. on 16.02.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

import SwiftUI

struct AppDescrView: UIViewRepresentable {

    private var attributedText: NSAttributedString {
        let c = Constants.self
        let text = String(format: c.appDescrWithPlaceholders, c.kp, c.noaaTitle, c.gfzTitle, c.ccBy40Title, c.imagePlaceholder, c.openSource)
        let font = UIFont.preferredFont(forTextStyle: .body)
        let italicFont = UIFont.italicSystemFont(ofSize: font.pointSize)
        let attrString = NSMutableAttributedString(string: text)
        attrString.set(font: font, forText: text)
        attrString.set(font: italicFont, forText: c.kp)
        attrString.set(url: c.noaaURL, forText: c.noaaTitle)
        attrString.set(url: c.gfzURL, forText: c.gfzTitle)
        attrString.set(url: c.ccBy40URL, forText: c.ccBy40Title)
        attrString.set(url: c.gitHubURL, forText: c.openSource)
        attrString.set(image: c.gitHubMarkImage, forText: c.imagePlaceholder, color: .label, capHeight: font.capHeight)
        return attrString
    }

    private var textView: UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = .clear
        textView.attributedText = attributedText
        textView.textAlignment = .center
        textView.textColor = .label
        return textView
    }

    func height(width: CGFloat) -> CGFloat {
        let fittingSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        let requiredSize = textView.sizeThatFits(fittingSize)
        return requiredSize.height
    }

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> UITextView {
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {}
}
