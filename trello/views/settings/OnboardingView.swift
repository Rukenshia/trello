//
//  OnboardingView.swift
//  trello
//
//  Created by Jan Christophersen on 13.10.22.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var preferences: Preferences;
    
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
                Spacer()
                
                TextField("trello key", text: $trelloKey)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 12))
                TextField("trello token", text: $trelloToken)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 12))
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
        OnboardingView(preferences: .constant(Preferences()))
    }
}
