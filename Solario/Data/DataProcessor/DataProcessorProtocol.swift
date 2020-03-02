//
//  DataProcessorProtocol.swift
//  Solario
//
//  Created by Hermann W. on 19.02.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

import Foundation

protocol DataProcessorProtocol {

    func prepare(items: [DataItem]) -> [Date:[DataItem]]

    func calculateMaxValues(itemsByDate: [Date:[DataItem]]) -> [Date:Float]

    func dateInterval(dates: [Date]) -> DateInterval?
}
