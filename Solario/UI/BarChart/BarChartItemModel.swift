//
//  BarChartItemModel.swift
//  Solario
//
//  Created by Aleksandr Pavlov on 09.05.22.
//  Copyright © 2022 Hermann Wagenleitner. All rights reserved.
//

import UIKit

struct BarChartItemModel: Hashable {

    let dayTitle: String

    let timeTitle: String

    let valueTitle: String

    let color: UIColor

    let heightRatio: CGFloat

    let showSeparator: Bool
}

