//
//  ContextMenuManageMembersView.swift
//  trello
//
//  Created by Jan Christophersen on 13.11.22.
//

import SwiftUI

struct ContextMenuManageMembersView: View {
  let members: [Member]
  let allMembers: [Member]
  
  let onAdd: (Member) -> Void
  let onRemove: (Member) -> Void
  var availableMembers: [Member] {
    self.allMembers.filter({ m in !self.members.contains(where: { mm in m.id == mm.id }) })
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      if !members.isEmpty {
        Text("Assigned")
          .font(.title3)
      }
      
      ForEach(members) { member in
        CardDetailsMemberView(member: member, onRemove: onRemove)
      }
      
      if !availableMembers.isEmpty {
        Text("Available")
          .font(.title3)
      }
      
      ForEach(availableMembers) { member in
        CardDetailsMemberView(member: member, onAdd: onAdd)
      }
    }
    .padding()
  }
}

struct ContextMenuManageMembersView_Previews: PreviewProvider {
  static var previews: some View {
    ContextMenuManageMembersView(members: [Member(id: "id", username: "username", avatarUrl: "https://via.placeholder.com", fullName: "full name", initials: "fn")], allMembers: [Member(id: "id", username: "username", avatarUrl: "https://via.placeholder.com", fullName: "full name", initials: "fn")], onAdd: { _ in }, onRemove: { _ in })
  }
}
