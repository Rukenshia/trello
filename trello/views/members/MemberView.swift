//
//  MemberView.swift
//  trello
//
//  Created by Jan Christophersen on 12.11.22.
//

import SwiftUI

struct MemberView: View {
  @Binding var member: Member
  
  var body: some View {
    HStack {
      MemberAvatarView(url: member.avatarUrl)
      .frame(width: 32, height: 32)
      Text(member.fullName)
        .lineLimit(1)
    }
  }
}

struct MemberView_Previews: PreviewProvider {
  static var previews: some View {
    MemberView(member: .constant(Member(id: "id", username: "username", avatarUrl: "https://via.placeholder.com/50", fullName: "full name", initials: "fn")))
  }
}
