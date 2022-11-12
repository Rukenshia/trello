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
      AsyncImage(url: URL(string: "\(member.avatarUrl)/50.png")) { phase in
        switch phase {
        case .empty:
          ProgressView()
        case .success(let image):
          image.resizable()
            .scaledToFit()
        case .failure:
          Image(systemName: "person")
            .foregroundColor(.red)
        @unknown default:
          EmptyView()
        }
      }
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
