//
//  trelloApp.swift
//  trello
//
//  Created by Jan Christophersen on 24.09.22.
//

import SwiftUI
import Sparkle

@main
struct trelloApp: App {
  @EnvironmentObject var trello: TrelloApi;
  @State var preferences: Preferences = Preferences();
  
  private let updaterController: SPUStandardUpdaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
  
  var body: some Scene {
    WindowGroup {
      if preferences.trelloKey != nil && preferences.trelloToken != nil {
        ContentView()
          .environmentObject(TrelloApi(key: preferences.trelloKey!, token: preferences.trelloToken!))
          .onAppear {
//            DevEnv()
          }
      } else {
        OnboardingView(preferences: $preferences)
      }
    }
    .commands {
      CommandGroup(after: .appInfo) {
        CheckForUpdatesView(updater: updaterController.updater)
      }
    }
    WindowGroup("Attachment", for: Attachment.self) { attachment in
      AttachmentDetailView(attachment: Binding(attachment)!, onDelete: {})
        .navigationTitle("Attachment - " + attachment.wrappedValue!.name)
        .environmentObject(TrelloApi(key: preferences.trelloKey!, token: preferences.trelloToken!))
    }
//    WindowGroup("Card", for: Card.self) { card in
//      CardDetailsView(card: Binding(card)!, isVisible: .constant(true))
//        .frame(minHeight: 600)
//        .navigationTitle("Card - " + card.wrappedValue!.name)
//        .environmentObject(TrelloApi(key: preferences.trelloKey!, token: preferences.trelloToken!))
//    }
  }
}
