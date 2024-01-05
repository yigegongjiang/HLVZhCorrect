//
//  HLVZhCorrectApp.swift
//  HLVZhCorrect
//
//  Created by gebiwanger on 2023/12/31.
//

import SwiftUI

@main
struct HLVZhCorrectApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
  @Environment(\.openWindow) private var openWindow
  
  var body: some Scene {

    Settings {
      SettingsView().environmentObject(AppConfigs.default)
    }
    
    MenuBarExtra("HLVZhCorrect", systemImage: "text.word.spacing") {
      Button("Open") {
        openWindow(id: "Text Correct")
      }
      
      Divider()
      
      SettingsLink(label: {
        Text("Settings")
      })
      .keyboardShortcut(",", modifiers: .command)
      
      Divider()
      
      Button("Quit") {
          NSApp.terminate(nil)
      }
      .keyboardShortcut("q", modifiers: .command)
    }.menuBarExtraStyle(.menu)
    
    Window("Text Correct", id: "Text Correct") {
      ContentView().environmentObject(AppConfigs.default)
    }
    .defaultSize(width: 800, height: 600)
  }
}

class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ notification: Notification) {
  }
}
