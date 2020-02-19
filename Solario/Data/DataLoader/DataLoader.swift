//
//  DataLoader.swift
//  Solario
//
//  Created by Hermann W. on 19.02.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

import Foundation

class DataLoader: DataLoaderProtocol {

    private let rawStorage: RawDataStorageProtocol

    private var loadingURLs: Set<URL> = []

    required init(rawStorage: RawDataStorageProtocol) {
        self.rawStorage = rawStorage
    }

    // MARK: - DataLoaderProtocol

    func load(reports: [ReportProtocol], completion: @escaping (() -> Void)) {
        guard reports.count > 0 else {
            completion()
            return
        }
        for report in reports {
            load(report: report, completion: { [weak self] in
                if self?.loadingURLs.count == 0 {
                    completion()
                }
            })
        }
    }

    // MARK: -

    private func load(report: ReportProtocol, completion: @escaping (() -> Void)) {
        loadingURLs.insert(report.url)
        retrieveRawDataFile(url: report.url, completion: { [weak self] rawDataFile in
            defer {
                completion()
            }
            self?.loadingURLs.remove(report.url)
            guard let file = rawDataFile else {
                return
            }
            report.setRawDataFile(file)
            self?.rawStorage.setRawDataFile(file, url: report.url)
        })
    }

    private func retrieveRawDataFile(url: URL, completion: @escaping (RawDataFile?) -> Void) {
        retrieveRawString(url: url, completion: { rawData in
            var rawDataFile: RawDataFile?
            if let rawData = rawData {
                rawDataFile = RawDataFile(text: rawData)
            }
            completion(rawDataFile)
        })
    }

    private func retrieveRawString(url: URL, completion: @escaping (String?) -> Void) {
        let task = URLSession.shared.downloadTask(with: url, completionHandler: {
            (location: URL?, response: URLResponse?, error: Error?) -> Void in
            guard let location = location else {
                completion(nil)
                return
            }
            let rawData: String?
            do {
                rawData = try String(contentsOf: location)
            } catch {
                print(error.localizedDescription)
                rawData = nil
            }
            completion(rawData)
        })
        task.resume()
    }
}
