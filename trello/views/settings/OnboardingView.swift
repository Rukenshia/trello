//
//  OnboardingView.swift
//  trello
//
//  Created by Jan Christophersen on 13.10.22.
//

import SwiftUI

struct OnboardingView: View {
  @Environment(\.openURL) var openURL
  @EnvironmentObject var preferences: Preferences;
  
  @State var trelloKey: String = "";
  @State var trelloToken: String = "";
  
  var body: some View {
    HStack {
      Spacer()
      VStack(alignment: .leading) {
        Text("Onboarding")
          .font(.largeTitle)
        Text("welcome to the best trello app ever, oder so")
          .foregroundColor(.secondary)
        
        VStack(alignment: .leading, spacing: 4) {
          Divider()
          
          Text("Instructions")
            .font(.title2)
          
          Text("Generate a power-up [here](https://trello.com/power-ups/admin/new):")
          
          Text(
"""
    name: desktop
    iframe: https://sync.in.fkn.space
""")
          
          Text("Next, navigate to 'API Key', take that as 'trello token' and click on the link on the right to generate a token. Put that into the token field below.")
          
          Divider()
        }
        
        TextField("trello key", text: $trelloKey)
          .textFieldStyle(.roundedBorder)
          .font(.system(size: 12))
        TextField("trello token", text: $trelloToken)
          .textFieldStyle(.roundedBorder)
          .font(.system(size: 12))
        
        Divider()
        
        VStack(alignment: .leading) {
          Text("Additional Tokens")
            .font(.title2)
          Text("The app can hit rate limits easily. Add additional tokens here if you need to")
            .foregroundColor(.secondary)
        }
        
        CredentialsSettingsView(credentials: preferences.credentials, onAdd: { k, t in
          preferences.credentials.insert(Credential(key: k, token: t), at: 0)
        }, onDelete: { credential in
          preferences.credentials = preferences.credentials.filter { c in c != credential }
        })
        
        Button(action: {
          if trelloKey != "" {
            preferences.trelloKey = trelloKey;
          }
          if trelloToken != "" {
            preferences.trelloToken = trelloToken;
          }
          
          preferences.save();
        }) {
          Text("Save")
        }
        Spacer()
      }
      Spacer()
    }
    .padding(64)
    .frame(minWidth: 600, minHeight: 400)
  }
}

struct OnboardingView_Previews: PreviewProvider {
  static var previews: some View {
    OnboardingView()
  }
}
