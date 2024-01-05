//
//  Tools.swift
//  HLVZhCorrect
//
//  Created by gebiwanger on 2024/1/6.
//

import Foundation
import HLVSentence

struct HLVParseInit {
  private init() {
    HLVParse.appendZhSymbol("///")
    HLVParse.appendZhSymbol("//")
    HLVParse.appendZhSymbol("/*")
    HLVParse.appendZhSymbol("*/")
  }
  static var `default`: HLVParseInit { HLVParseInit() }
}
