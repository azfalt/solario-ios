//
//  RawDataRetriever.swift
//  Solario
//
//  Created by Hermann Wagenleitner on 13/06/2017.
//  Copyright © 2017 Hermann Wagenleitner. All rights reserved.
//

import Foundation

class RawDataRetriever: RawDataRetrieverProtocol {

    func retrieveRawDataFile(url: URL, completion: @escaping (RawDataFile?) -> Void) {
        retrieveRawString(url: url, completion: { rawData in
            var rawDataFile: RawDataFile?
            if let rawData = rawData  {
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
