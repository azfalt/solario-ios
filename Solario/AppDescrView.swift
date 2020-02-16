//
//  AppDescrView.swift
//  Solario
//
//  Created by Hermann W. on 16.02.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

import SwiftUI

struct AppDescrView: UIViewRepresentable {

    private let attributedText: NSAttributedString = {
        let text = String(format: "_data_provision_with_placeholders".localized,
                          "_kp".localized,
                          "_noaa_title".localized,
                          "_gfz_title".localized,
                          "_cc_by_40_title".localized)
        let font = UIFont.preferredFont(forTextStyle: .body)
        let italicFont = UIFont.italicSystemFont(ofSize: font.pointSize)
        let noaaUrl = URL(string: "_noaa_url".localized)!
        let gfzUrl = URL(string: "_gfz_url".localized)!
        let ccBy40URL = URL(string: "_cc_by_40_url".localized)!
        let attrString = NSMutableAttributedString(string: text)
        attrString.set(font: font, forText: text)
        attrString.set(font: italicFont, forText: "_kp".localized)
        attrString.set(url: noaaUrl, forText: "_noaa_title".localized)
        attrString.set(url: gfzUrl, forText: "_gfz_title".localized)
        attrString.set(url: ccBy40URL, forText: "_cc_by_40_title".localized)
        return attrString
    }()

    private var textView: UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.backgroundColor = .clear
        textView.attributedText = attributedText
        textView.textAlignment = .center
        textView.textColor = .label
        return textView
    }

    func height(width: CGFloat) -> CGFloat {
        let view = textView
        view.frame = CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude)
        view.sizeToFit()
        return view.frame.height + 1
    }

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> UITextView {
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {}
}
