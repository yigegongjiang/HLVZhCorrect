//
//  ContentView.swift
//  HLVZhCorrect
//
//  Created by gebiwanger on 2023/12/31.
//

import Foundation
import SwiftUI
import HLVSentence
import Down
import UniformTypeIdentifiers
import AppKit

struct ContentView: View {
  @EnvironmentObject var appConfigs: AppConfigs
  
  @State private var isFilePickerPresented = false
  
  @State private var sentences: String = "Empty." {
    didSet {
      sentences_back = sentences
    }
  }
  @State private var sentences_back: String = "Empty."// 用于保障 TextEditor 内容不被误更改。对于 SwiftUI 而言，TextEditor 具有文本复制的能力。
  
  @State private var corrects: String = "Empty." {
    didSet {
      corrects_back = corrects
    }
  }
  @State private var corrects_back: String = "Empty."
  
  var body: some View {
    HSplitView {
      VStack {
        Spacer()
        Button {
          isFilePickerPresented = true
        } label: {
          VStack {
            Text("Open")
            Text("File")
          }.font(.system(size: 10))
        }
        .fileImporter(
          isPresented: $isFilePickerPresented,
          allowedContentTypes: [UTType.plainText],
          allowsMultipleSelection: false
        ) { result in
          switch result {
          case .success(let urls):
            do {
              let file = try openFile(urls[0], encoding: .utf8)
              
              defer {
                file.close()
              }
              
              var raw = try file.read()
              
              if appConfigs.appsettings.needMarkdown {
                raw = (try? Down(markdownString: raw).toAttributedString([.hardBreaks]).string) ?? ""
              }
              parseText(raw)
            } catch {
            }
          case .failure(let n):
            let _ = n
          }
        }
        
        Button("Paste") {
          let pasteboard = NSPasteboard.general
          var raw = pasteboard.string(forType: .string) ?? ""
          if appConfigs.appsettings.needMarkdown {
            raw = (try? Down(markdownString: raw).toAttributedString([.hardBreaks]).string) ?? ""
          }
          parseText(raw)
        }.font(.system(size: 10))
        Spacer()
      }.frame(width: 50)
      
      HSplitView {
        TextEditor(text: $sentences)
          .lineSpacing(8)
          .onChange(of: sentences, {
            sentences = sentences_back
          })
          .frame(maxWidth: .infinity, maxHeight:.infinity)
        
        TextEditor(text: $corrects)
          .onChange(of: corrects, {
            corrects = corrects_back
          })
          .frame(maxWidth: .infinity, maxHeight:.infinity)
      }
    }
    .frame(idealWidth: 800, idealHeight: 600)
  }
  
  func parseText(_ text: String) {
    sentences = "waiting..."
    if appConfigs.appsettings.needCorrect {
      corrects = "waiting..."
    }
    
    _ = HLVParseInit.default
    
    var r: [String]
    if appConfigs.appsettings.needZh_cn {
      r = HLVParse.parseZh(text, minWords: appConfigs.appsettings.minSentenceWords)
    } else {
      r = HLVParse.parse(text, minWords: appConfigs.appsettings.minSentenceWords)
    }
    
    guard !r.isEmpty else {
      sentences = "Cannot find effective sentence."
      if appConfigs.appsettings.needCorrect {
        corrects = "Interrupt."
      }
      return
    }
    
    var index = 0
    let m = r.map { v in
      index += 1
      return "\(index): \(v)"
    }
    sentences = m.joined(separator: "\n")
    sentences_back = m.joined(separator: "\n")
    
    if !r.isEmpty, appConfigs.appsettings.needCorrect {
      HLVTextCorrect.envPath = appConfigs.appsettings.path
      HLVTextCorrect.correct(r) { (result: Result<HLVTextCorrectResult, HLVTextCorrectError>) in
        switch result {
        case .success(let m):
          if m.isEmpty {
            corrects = "All is OK, has no words need Correct."
          } else {
            corrects = m.map { (v: (first: String, last: String, errors: [Any])) in
              let (first, last, errors) = v
              return "O: \(first)\nN: \(last)\nDiff: \(errors.map { "\($0)" }.joined(separator: ","))"
            }.joined(separator: "\n------------\n")
          }
        case .failure(_):
          corrects = "Text Correct Field. May need to install python3 and pycorrector, see: https://github.com/shibing624/pycorrector. If all ok, may set PATH to setting."
        }
      }
    }
  }
}

#Preview {
  ContentView().environmentObject(AppConfigs.default)
}
