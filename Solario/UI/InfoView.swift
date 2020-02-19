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

    private let appDescrView = AppDescrView()

    var appVersionString: String {
        return String(format: Constants.appVersionWithPlaceholder, Bundle.main.appVersion)
    }

    private let verticalSpacing: CGFloat = 20

    private let horizontalPadding: CGFloat = 10

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ScrollView(.vertical) {
                    VStack(alignment: .center, spacing: self.verticalSpacing) {
                        Spacer()
                        Text(Constants.appName).font(.largeTitle).bold()
                        Text(self.appVersionString).font(.caption).padding(.top, -self.verticalSpacing)
                        self.appDescrView
                            .padding(.horizontal, self.horizontalPadding)
                            .frame(width: geometry.size.width,
                                   height: self.appDescrView.height(width: (geometry.size.width - self.horizontalPadding * 2)),
                                   alignment: .center)
                        Spacer()
                        Spacer()
                    }
                    .frame(minHeight: geometry.size.height)
                }
                VStack(alignment: .center, spacing: self.verticalSpacing) {
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
