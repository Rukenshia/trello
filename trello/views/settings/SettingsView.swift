//
//  SettingsView.swift
//  trello
//
//  Created by Jan Christophersen on 09.03.23.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
      TabView {
        LookAndFeelSettingsView()
          .tabItem {
            SwiftUI.Label("Look and Feel", systemImage: "photo.fill")
          }
        
        OnboardingView()
          .tabItem {
            SwiftUI.Label("API Settings", systemImage: "key")
          }
      }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
      SettingsView()
    }
}
