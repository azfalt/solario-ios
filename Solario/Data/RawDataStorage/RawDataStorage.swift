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

    private let key = "storage"

    private var texts = [String: String]()

    init() {
        tryLoadFromDefaults()
    }

    // MARK: - RawDataStorageProtocol

    func rawDataFile(url: URL) -> RawDataFile? {
        if let text = texts[url.absoluteString] {
            return RawDataFile(text: text)
        }
        return nil
    }

    func setRawDataFile(_ file: RawDataFile, url: URL) {
        texts[url.absoluteString] = file.text
        saveToDefaults()
    }

    // MARK: -

    private func tryLoadFromDefaults() {
        if let texts = defaults.object(forKey: key) as? [String: String] {
            self.texts = texts
        }
    }

    private func saveToDefaults() {
        defaults.set(texts, forKey: key)
        defaults.synchronize()
    }
}
