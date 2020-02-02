//
//  TimeServiceProtocol.swift
//  Solario
//
//  Created by Hermann W. on 02.02.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

import Foundation

protocol TimeServiceProtocol {

    var day: Observable<Int> { get }

    func start()

    func stop()
}
