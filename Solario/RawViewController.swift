//
//  RawViewController.swift
//  Solario
//
//  Created by Hermann Wagenleitner on 03/08/2017.
//  Copyright © 2017 Hermann Wagenleitner. All rights reserved.
//

import UIKit

class RawViewController: UIViewController {

    public var report: Report!

    private let textView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.isScrollEnabled = true
    }

    private func configure() {
        title = "Raw"
        configureNavigationButtons()
        configureTextView()
    }

    private func configureNavigationButtons() {
        let safariButton = UIBarButtonItem(title: "_action_open".localized, style: .plain, target: self, action: #selector(openInSafari))
        navigationItem.rightBarButtonItem = safariButton
    }

    private func configureTextView() {
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        textView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.text = report.rawDataFile?.text
        let fontSize = UIFont.preferredFont(forTextStyle: .footnote).pointSize
        textView.font = UIFont(name: "Menlo-Regular", size: fontSize)
        textView.textColor = Appearance.textColor
        textView.backgroundColor = Appearance.bgColor
    }

    @objc private func openInSafari() {
        if let url = report.fileURL {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
