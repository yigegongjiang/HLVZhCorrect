//
//  AppConfigs.swift
//  HLVZhCorrect
//
//  Created by gebiwanger on 2024/1/5.
//

import Foundation
import SwiftUI

struct AppSettings: Codable {
  var autoLaunch: Bool = false {
    didSet { save() }
  }
  
  var needMarkdown: Bool = true {
    didSet { save() }
  }
  var needCorrect: Bool = true {
    didSet { save() }
  }
  var needZh_cn: Bool = true {
    didSet { save() }
  }
  var minSentenceWords: UInt8 = 5 {
    didSet { save() }
  }
  
  var path: String = "" {
    didSet { save() }
  }
  
  static let userdefaultKey = "com.zhchrrect.appsettings"
  
  private init() { }
  
  static var `default` = AppSettings()
  
  func save() {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(self) {
        UserDefaults.standard.set(encoded, forKey: AppSettings.userdefaultKey)
    }
  }
}

class AppConfigs: ObservableObject {
  @Published var appsettings: AppSettings!
  
  private init() {
    load()
  }
  
  static var `default` = AppConfigs()
  
  func load() {
    guard let data = UserDefaults.standard.object(forKey: AppSettings.userdefaultKey) as? Data else {
      appsettings = AppSettings.default
      return
    }
    let decoder = JSONDecoder()
    guard let obj = try? decoder.decode(AppSettings.self, from: data) else {
      appsettings = AppSettings.default
      return
    }
    appsettings = obj
  }
}
