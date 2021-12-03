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

    func load(reports: [ReportProtocol], completion: @escaping LoadCompletion) {
        guard reports.count > 0 else {
            completion(false)
            return
        }
        var isSuccessful = false
        for report in reports {
            load(report: report, completion: { [weak self] success in
                isSuccessful = isSuccessful || success
                if self?.loadingURLs.count == 0 {
                    completion(isSuccessful)
                }
            })
        }
    }

    // MARK: -

    private func load(report: ReportProtocol, completion: @escaping LoadCompletion) {
        loadingURLs.insert(report.url)
        retrieveRawDataFile(url: report.url, completion: { [weak self] rawDataFile in
            self?.loadingURLs.remove(report.url)
            guard let file = rawDataFile else {
                completion(false)
                return
            }
            report.setRawDataFile(file)
            self?.rawStorage.setRawDataFile(file, url: report.url)
            completion(true)
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
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        let task = URLSession.shared.downloadTask(with: request) {
            (location: URL?, response: URLResponse?, error: Error?) -> Void in
            guard
                let response = response as? HTTPURLResponse,
                200...299 ~= response.statusCode,
                let location = location else {
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
        }
        task.resume()
    }
}
