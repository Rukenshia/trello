//
//  SettingsView.swift
//  trello
//
//  Created by Jan Christophersen on 09.03.23.
//

import SwiftUI

struct SettingsView: View {
  @Binding var preferences: Preferences
  
    var body: some View {
      TabView {
        LookAndFeelSettingsView(preferences: $preferences)
          .tabItem {
            SwiftUI.Label("Look and Feel", systemImage: "photo.fill")
          }
        
        OnboardingView(preferences: $preferences)
          .tabItem {
            SwiftUI.Label("API Settings", systemImage: "key")
          }
      }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
      SettingsView(preferences: .constant(Preferences()))
    }
}
