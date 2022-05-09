//
//  BarChartModelsFactoryProtocol.swift
//  Solario
//
//  Created by Aleksandr Pavlov on 09.05.22.
//  Copyright © 2022 Hermann Wagenleitner. All rights reserved.
//

import Foundation

protocol BarChartModelsFactoryProtocol {

    func models(with items: [DataItem], allowSeparator: Bool) -> [BarChartItemModel]
}
