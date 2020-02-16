//
//  EdgeButton.swift
//  Solario
//
//  Created by Hermann W. on 16.02.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

import SwiftUI

struct EdgeButton: View {

    var action: (() -> Void)

    private let size: CGSize = CGSize(width: 35, height: 5)

    var body: some View {
        return Button(action: {
            self.action()
        }) {
            Text("         ")
        }
        .frame(width: size.width, height: size.height, alignment: .center)
        .background(UIColor.tertiaryLabel.color)
        .cornerRadius(size.height / 2)
    }
}
