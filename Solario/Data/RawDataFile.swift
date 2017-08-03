//
//  RawDataFile.swift
//  Solario
//
//  Created by Herman Wagenleitner on 13/06/2017.
//  Copyright © 2017 Herman Wagenleitner. All rights reserved.
//

import Foundation

//protocol RawDataFileProtocol {
//
//  //  init(text: String)//tmp
//
//  static var url: URL { get }
//
////  var url: URL { get }
//
//  var text: String { get }
//
//  var lines: [String] { get }
//}
//
//extension RawDataFileProtocol {
//
//  var lines: [String] {
//    return text.components(separatedBy: .newlines)
//  }
//}

struct RawDataFile {

  let text: String

  var lines: [String] {
    return text.components(separatedBy: .newlines)
  }
}
