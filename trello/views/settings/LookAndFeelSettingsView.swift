//
//  LookAndFeelSettingsView.swift
//  trello
//
//  Created by Jan Christophersen on 09.03.23.
//

import SwiftUI

struct LookAndFeelSettingsView: View {
  @EnvironmentObject var preferences: Preferences
  
  @State private var selection: String = "compact"
  
    var body: some View {
      VStack {
        Picker("Due date", selection: $selection) {
          CardDueView(card: .constant(Card(id: "card-id", name: "card name", due: TrelloApi.DateFormatter.string(from: Date.now.advanced(by: 5)))), isHovering: false)
            .allowsHitTesting(false)
            .tag("full")
          
          CardDueView(card: .constant(Card(id: "card-id", name: "card name", due: TrelloApi.DateFormatter.string(from: Date.now.advanced(by: 5)))), compact: true, isHovering: false)
            .allowsHitTesting(false)
            .tag("compact")
        }
        .pickerStyle(.inline)
        Spacer()
      }
      .padding()
      .frame(minWidth: 300, minHeight: 200)
      .onAppear {
        selection = preferences.compactDueDate ? "compact" : "full"
      }
      .onChange(of: selection) { newMode in
        preferences.compactDueDate = newMode == "compact"
        preferences.save()
      }
    }
}

struct LookAndFeelSettingsView_Previews: PreviewProvider {
    static var previews: some View {
      LookAndFeelSettingsView()
        .environmentObject(TrelloApi.testing)
        .frame(width: 300, height: 200)
    }
}
