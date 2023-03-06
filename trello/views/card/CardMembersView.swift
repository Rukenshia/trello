//
//  CardMembersView.swift
//  trello
//
//  Created by Jan Christophersen on 12.11.22.
//

import SwiftUI

struct CardMembersView: View {
  var members: [Member]
  
  var body: some View {
    HStack {
      ForEach(members) { member in
        if let url = member.avatarUrl {
          MemberAvatarView(url: url)
            .frame(width: 24, height: 24)
        }
      }
    }
  }
}

struct CardMembersView_Previews: PreviewProvider {
  static var previews: some View {
    CardMembersView(members: [Member(id: "id", username: "username", avatarUrl: "https://via.placeholder.com/50", fullName: "full name", initials: "fn"), Member(id: "id2", username: "username", avatarUrl: "https://via.placeholder.com/50", fullName: "full name two", initials: "fn")])
  }
}
