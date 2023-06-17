//
//  trelloApp.swift
//  trello
//
//  Created by Jan Christophersen on 24.09.22.
//

import SwiftUI
import Sparkle

struct VisualEffectView: NSViewRepresentable {
  func makeNSView(context: Context) -> NSVisualEffectView {
    let view = NSVisualEffectView()
    
    view.blendingMode = .behindWindow
    view.state = .active
    view.material = .underWindowBackground
    
    return view
  }
  
  func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
    //
  }
}

@main
struct trelloApp: App {
  @State var preferences: Preferences
  @State var appState: AppState
  @State var trelloApi: TrelloApi
  
  @State private var showCommandBar: Bool
  
  private let updaterController: SPUStandardUpdaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
  
  init() {
    self.preferences = Preferences()
    self.trelloApi = TrelloApi()
    self.appState = AppState(api: nil)
    self.showCommandBar = false
    
    trelloApi.setAuth(key: preferences.trelloKey!, token: preferences.trelloToken!, credentials: preferences.credentials)
    appState.api = trelloApi
  }
  
  var body: some Scene {
    Settings {
      SettingsView()
        .environmentObject(preferences)
    }
    
    WindowGroup {
      if preferences.trelloKey != nil && preferences.trelloToken != nil {
        ContentView(showCommandBar: $showCommandBar)
          .environmentObject(preferences)
          .environmentObject(appState)
          .environmentObject(trelloApi)
          .onAppear {
            DevEnv()
          }
        //          .preferredColorScheme(.light)
      } else {
        OnboardingView()
          .environmentObject(preferences)
      }
    }
    .commands {
      CommandGroup(after: .appInfo) {
        CheckForUpdatesView(updater: updaterController.updater)
      }
      SidebarCommands()
      CommandGroup(after: .newItem) {
        Button("Open Command Bar") {
          showCommandBar.toggle()
        }
        .keyboardShortcut("p", modifiers: [.command])
      }
    }
    WindowGroup("Attachment", for: Attachment.self) { attachment in
      AttachmentDetailView(attachment: attachment.wrappedValue!, onDelete: {})
        .navigationTitle("Attachment - " + attachment.wrappedValue!.name)
        .environmentObject(TrelloApi(key: preferences.trelloKey!, token: preferences.trelloToken!, credentials: preferences.credentials))
    }
  }
}
