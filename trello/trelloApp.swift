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
  @State var preferences: Preferences = Preferences()
  @State private var showCommandBar = false
  
  private let updaterController: SPUStandardUpdaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
  
  var body: some Scene {
    Settings {
      OnboardingView(preferences: $preferences)
    }
    
    WindowGroup {
      if preferences.trelloKey != nil && preferences.trelloToken != nil {
        ContentView(showCommandBar: $showCommandBar)
          .environmentObject(TrelloApi(key: preferences.trelloKey!, token: preferences.trelloToken!))
          .environmentObject(preferences)
          .onAppear {
//            DevEnv()
          }
//          .preferredColorScheme(.light)
      } else {
        OnboardingView(preferences: $preferences)
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
      AttachmentDetailView(attachment: Binding(attachment)!, onDelete: {})
        .navigationTitle("Attachment - " + attachment.wrappedValue!.name)
        .environmentObject(TrelloApi(key: preferences.trelloKey!, token: preferences.trelloToken!))
    }
  }
}
