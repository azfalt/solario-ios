//
//  BarChartView.swift
//  Solario
//
//  Created by Aleksandr Pavlov on 09.05.22.
//  Copyright © 2022 Hermann Wagenleitner. All rights reserved.
//

import SwiftUI

struct BarChartView: View {

    let items: [BarChartItemModel]

    let dayFont = Font.system(size: 12, weight: .medium, design: .rounded)
    let timeFont = Font.system(size: 10, weight: .semibold, design: .rounded)
    let valueFont = Font.system(size: 12, weight: .bold, design: .rounded)

    var body: some View {

        HStack {

            ForEach(items, id: \.self) { item in

                if item.showSeparator {

                    Rectangle()
                        .fill(UIColor.systemGray4.color)
                        .frame(width: 1, alignment: .center)
                }

                VStack(spacing: 5) {

                    Text(item.dayTitle)
                        .font(dayFont)
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                        .fixedSize(horizontal: true, vertical: false)
                        .frame(width: 25, height: 15, alignment: .leading)

                    GeometryReader { metrics in

                        ZStack {

                            VStack() {
                                Spacer()

                                Rectangle()
                                    .fill(item.color.color)
                                    .frame(height: metrics.size.height * item.heightRatio * 0.85)
                                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                            }

                            VStack {
                                Spacer()
                                Text(item.valueTitle)
                                    .font(valueFont)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.1)
                                    .foregroundColor(.black)
                                    .opacity(0.5)
                                    .padding(.bottom, 5)
                            }
                        }
                        .padding(.bottom, 5)
                    }

                    Text(item.timeTitle)
                        .font(timeFont)
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                        .frame(width: 25, height: 10, alignment: .center)
                }
            }
        }
    }
}
