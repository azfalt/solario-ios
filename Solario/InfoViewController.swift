//
//  InfoViewController.swift
//  Solario
//
//  Created by Hermann W. on 08.02.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

import UIKit
import SwiftUI

class InfoViewController: UIHostingController<InfoView> {

    required init() {
        super.init(rootView: InfoView())
        rootView.dismissAction = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
