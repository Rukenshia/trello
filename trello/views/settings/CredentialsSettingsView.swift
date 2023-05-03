//
//  TokensSettingsView.swift
//  trello
//
//  Created by Jan Christophersen on 28.03.23.
//

import SwiftUI

struct CredentialView: View {
  let credential: Credential
  
  let onDelete: () -> Void
  
  var body: some View {
    HStack {
      Text(credential.key)
      Spacer()
      Text(credential.token)
        .foregroundColor(.secondary)
      Spacer()
      Button(action: onDelete) {
        Image(systemName: "trash")
          .buttonStyle(.borderless)
      }
    }
  }
}

struct CredentialsSettingsView: View {
  let credentials: [Credential]
  
  let onAdd: (String, String) -> Void
  let onDelete: (Credential) -> Void
  
  @State private var showAdd: Bool = true
  @State private var key = ""
  @State private var token = ""
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text("Keys")
          .font(.title3)
        
        Spacer()
        
        Button(action: {
          showAdd = true
        }) {}
        .buttonStyle(FlatButton(icon: "plus", text: "Add"))
      }
      
      if showAdd {
        HStack {
          TextField("key", text: $key)
          TextField("token", text: $token)
          Button(action: {
            onAdd(key, token)
            
            showAdd = false
            key = ""
            token = ""
          }) {
            Text("Save")
          }
        }
        .textFieldStyle(.roundedBorder)
        .padding(4)
      }
      
      Divider()
      
      if credentials.count == 0 {
        HStack {
          Spacer()
          
          Text("_No credentials added yet_")
            .foregroundColor(.secondary)
            .padding()
          Spacer()
        }
      }
      
      ForEach(credentials, id: \.self) { credential in
        CredentialView(credential: credential, onDelete: {
          onDelete(credential)
        })
      }
    }
  }
}

struct CredentialsSettingsView_Previews: PreviewProvider {
  static var previews: some View {
    CredentialsSettingsView(credentials: [Credential(key: "key", token: "token")], onAdd: { _, _ in }, onDelete: { _ in })
  }
}
