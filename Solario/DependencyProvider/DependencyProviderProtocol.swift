//
//  DependencyProviderProtocol.swift
//  Solario
//
//  Created by Hermann W. on 01.02.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

import Foundation

protocol DependencyProviderProtocol {

    var timeService: TimeServiceProtocol { get }

    var appearance: AppearanceProtocol { get }

    var dataInteractor: DataInteractorProtocol { get }
}
