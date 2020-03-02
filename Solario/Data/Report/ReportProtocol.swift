//
//  ReportProtocol.swift
//  Solario
//
//  Created by Hermann W. on 19.02.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

import Foundation

protocol ReportProtocol {

    var url: URL { get }

    var priority: DataItemPriority { get }

    var items: [DataItem]? { get }

    var rawDataFile: RawDataFile? { get }

    func setRawDataFile(_ file: RawDataFile)
}
