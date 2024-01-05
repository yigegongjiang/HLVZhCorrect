//
//  SettingsView.swift
//  HLVZhCorrect
//
//  Created by gebiwanger on 2024/1/4.
//

import Foundation
import SwiftUI
import ServiceManagement

struct SettingsView: View {
  @EnvironmentObject var appConfigs: AppConfigs
  
  @State private var isShowingAlert = false

  var body: some View {
    Form {
      VStack {
        VStack(alignment: .leading){
          Toggle("Launch at login", isOn: $appConfigs.appsettings.autoLaunch)
            .onChange(of: appConfigs.appsettings.autoLaunch) { (_,_) in
              if appConfigs.appsettings.autoLaunch {
                try? SMAppService().register()
              } else {
                try? SMAppService().unregister()
              }
            }

          Toggle("启用 Markdown 渲染", isOn: $appConfigs.appsettings.needMarkdown)
          Toggle("启用 中文 检测", isOn: $appConfigs.appsettings.needZh_cn)
          Toggle("启用 错别字 检测", isOn: $appConfigs.appsettings.needCorrect)
          HStack {
            Text("最少分句单词数: \(appConfigs.appsettings.minSentenceWords)")
            Stepper("", value: $appConfigs.appsettings.minSentenceWords, in: 1...255)
              .padding(.leading, -8)
          }
        }
        
        Divider()
        
        VStack(alignment:.leading) {
          HStack {
            Text("自定义脚本终端 PATH")
            Button(action: {
              isShowingAlert = true
            }) {
              Image(systemName: "questionmark.circle")
            }
            .alert(isPresented: $isShowingAlert) {
              Alert(
                title: Text("提示"),
                message: Text("中文错别字检测依赖 pycorrector 引擎，需要提前安装(https://github.com/shibing624/pycorrector)。若使用 Conda 等 python 虚拟环境，则需要配置执行环境。可通过 `echo $PATH` 获取当前终端的 PATH 并黏贴到下面的输入框中。")
              )
            }
          }
          
          TextEditor(text: $appConfigs.appsettings.path)
            .frame(width: 300, height: 100)
        }
      }
    }
    .frame(minWidth: 500, idealWidth: 500, maxWidth: .infinity, minHeight: 300, idealHeight: 300, maxHeight: .infinity)
  }
}

#Preview {
  SettingsView().environmentObject(AppConfigs.default)
}
