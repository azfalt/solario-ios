//
//  RawDataStorageProtocol.swift
//  Solario
//
//  Created by Hermann W. on 01.02.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

import Foundation

protocol RawDataStorageProtocol {

    func rawDataFile(url: URL) -> RawDataFile?

    func setRawDataFile(_ file: RawDataFile, url: URL)
}
