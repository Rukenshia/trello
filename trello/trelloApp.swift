//
//  trelloApp.swift
//  trello
//
//  Created by Jan Christophersen on 24.09.22.
//

import SwiftUI

@main
struct trelloApp: App {
    @EnvironmentObject var trello: TrelloApi;
    @State var preferences: Preferences = Preferences();
    
    var body: some Scene {
        WindowGroup {
            if preferences.trelloKey != nil && preferences.trelloToken != nil {
                ContentView()
                    .environmentObject(TrelloApi(key: preferences.trelloKey!, token: preferences.trelloToken!))
            } else {
                OnboardingView(preferences: $preferences)
            }
        }
    }
}
