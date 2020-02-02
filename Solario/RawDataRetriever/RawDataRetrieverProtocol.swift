//
//  RawDataRetrieverProtocol.swift
//  Solario
//
//  Created by Hermann W. on 01.02.20.
//  Copyright © 2020 Hermann Wagenleitner. All rights reserved.
//

import Foundation


protocol RawDataRetrieverProtocol {

    func retrieveRawDataFile(url: URL, completion: @escaping (RawDataFile?) -> Void)
}
