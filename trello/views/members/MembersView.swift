//
//  MembersView.swift
//  trello
//
//  Created by Jan Christophersen on 12.11.22.
//

import SwiftUI

struct MembersView: View {
  @Binding var members: [Member]
  var body: some View {
    VStack(alignment: .leading) {
      ForEach($members) { member in
        MemberView(member: member)
      }
    }
    .padding()
  }
}

struct MembersView_Previews: PreviewProvider {
  static var previews: some View {
    MembersView(members: .constant([Member(id: "id", username: "username", avatarUrl: "https://via.placeholder.com/50", fullName: "full name", initials: "fn")]))
  }
}
