//
//  InfoView.swift
//  Solario
//
//  Created by Hermann W. on 09.02.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

import SwiftUI

struct InfoView: View {

    var dismissAction: (() -> Void)?

    private let appIconView = AppIconView()

    private let appDescrView = AppDescrView()

    private var appVersionString: String {
        return String(format: Constants.appVersionWithPlaceholder, Bundle.main.appVersion)
    }

    private let horizontalPadding: CGFloat = 10

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ScrollView(.vertical) {
                    VStack(alignment: .center, spacing: 20) {
                        VStack(alignment: .center, spacing: 0) {
                            self.appIconView.padding(.bottom, 3)
                            Text(Constants.appName).font(.largeTitle).bold()
                            Text(self.appVersionString).font(.caption)
                        }
                        self.appDescrView
                            .padding(.horizontal, self.horizontalPadding)
                            .frame(width: geometry.size.width,
                                   height: self.appDescrView.height(width: (geometry.size.width - self.horizontalPadding * 2)),
                                   alignment: .center)
                    }
                    .frame(minHeight: geometry.size.height)
                }
                VStack(alignment: .center) {
                    HStack(alignment: .center) {
                        Spacer()
                        EdgeButton() {
                            self.dismissAction?()
                        }.padding()
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}
