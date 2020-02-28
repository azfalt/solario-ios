//
//  AppIconView.swift
//  Solario
//
//  Created by Hermann W. on 28.02.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

import SwiftUI

struct AppIconView: View {

    private var image: Image? {
        if let uiImage = Bundle.main.appIcon {
            return Image(uiImage: uiImage)
        }
        return nil
    }

    private var clipShape: RoundedRectangle {
        let radius: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 18 : 15
        return RoundedRectangle(cornerRadius: radius, style: .continuous)
    }

    var body: some View {
        return image.clipShape(clipShape)
    }
}
