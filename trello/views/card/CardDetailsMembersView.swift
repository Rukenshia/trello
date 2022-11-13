//
//  CardDetailsMembersView.swift
//  trello
//
//  Created by Jan Christophersen on 13.11.22.
//

import SwiftUI

struct CardDetailsMemberView: View {
  let member: Member
  var onRemove: ((Member) -> Void)?
  var onAdd: ((Member) -> Void)?
  
  var body: some View {
    HStack {
      MemberAvatarView(url: member.avatarUrl)
        .frame(width: 32, height: 32)
      Text(member.fullName)
      Spacer()
      if let onRemove = self.onRemove {
        Button(action: {
          onRemove(member)
        }) {
          Image(systemName: "xmark")
            .padding(.horizontal, 8)
        }
        .buttonStyle(.plain)
      }
      if let onAdd = self.onAdd {
        Button(action: {
          onAdd(member)
        }) {
          Image(systemName: "plus")
            .padding(.horizontal, 8)
        }
        .buttonStyle(.plain)
      }
    }
  }
}

struct CardDetailsMembersView: View {
  let members: [Member]
  let allMembers: [Member]
  
  let onAdd: (Member) -> Void
  let onRemove: (Member) -> Void
  
  @State private var hover = false
  @State private var popover = false
  
  var body: some View {
    Button(action: {
      self.popover = true
    }) {
      HStack {
        ForEach(members) { member in
          MemberAvatarView(url: member.avatarUrl)
            .frame(width: 32, height: 32)
        }
        Circle()
          .fill(Color("TwZinc600"))
          .frame(width: 32, height: 32)
          .overlay {
            Image(systemName: "plus")
              .bold()
          }
        Spacer()
      }
      .padding(4)
      .background(self.hover ? Color("TwZinc700") : .clear)
      .cornerRadius(8)
      .onHover { hover in
        withAnimation(.easeInOut(duration: 0.1)) {
          self.hover = hover
        }
      }
      .popover(isPresented: $popover, arrowEdge: .bottom) {
        ContextMenuManageMembersView(members: members, allMembers: allMembers, onAdd: onAdd, onRemove: onRemove)
      }
    }
    .buttonStyle(.plain)
  }
}

struct CardDetailsMembersView_Previews: PreviewProvider {
  static var previews: some View {
    CardDetailsMembersView(members: [Member(id: "id", username: "username", avatarUrl: "https://via.placeholder.com", fullName: "full name", initials: "fn")], allMembers: [Member(id: "id", username: "username", avatarUrl: "https://via.placeholder.com", fullName: "full name", initials: "fn")], onAdd: { _ in }, onRemove: { _ in })
  }
}
