//
//  RawDataStorage.swift
//  Solario
//
//  Created by Hermann W. on 08.01.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

import Foundation

class RawDataStorage: RawDataStorageProtocol {

    private let defaults = UserDefaults.standard

    func rawDataFile(url: URL) -> RawDataFile? {
        if let text = defaults.string(forKey: url.absoluteString) {
            return RawDataFile(text: text)
        }
        return nil
    }

    func set(rawDataFile: RawDataFile, url: URL) {
        defaults.set(rawDataFile.text, forKey: url.absoluteString)
        defaults.synchronize()
    }
}
