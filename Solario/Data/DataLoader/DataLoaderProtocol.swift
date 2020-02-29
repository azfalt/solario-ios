//
//  DataLoaderProtocol.swift
//  Solario
//
//  Created by Hermann W. on 19.02.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

import Foundation

protocol DataLoaderProtocol {

    typealias LoadCompletion = ((_ success: Bool) -> Void)

    func load(reports: [ReportProtocol], completion: @escaping LoadCompletion)
}
