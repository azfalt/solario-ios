//
//  DataInteractorProtocol.swift
//  Solario
//
//  Created by Hermann W. on 16.02.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

import Foundation

protocol DataInteractorProtocol {

    typealias LoadCompletion = ((_ success: Bool) -> Void)

    var isProcessing: Observable<Bool> { get }

    var dateInterval: DateInterval? { get }

    func maxValue(forDate date: Date) -> Float?

    func items(forDate date: Date) -> [DataItem]

    func loadData(completion: LoadCompletion?)
}
