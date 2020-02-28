//
//  CGFloat.swift
//  Solario
//
//  Created by Hermann W. on 28.02.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

import UIKit

extension CGFloat {

    var roundedToPixel: CGFloat {
        let pixelLength = 1 / UIScreen.main.scale
        let numOfPixels = self / pixelLength
        let result: CGFloat = numOfPixels.rounded() * pixelLength
        return result
    }
}
