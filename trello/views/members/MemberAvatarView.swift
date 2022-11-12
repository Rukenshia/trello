//
//  MemberAvatarView.swift
//  trello
//
//  Created by Jan Christophersen on 12.11.22.
//

import SwiftUI

struct MemberAvatarView: View {
  var url: String
  var size: Int = 50
  
  var body: some View {
    AsyncImage(url: URL(string: "\(url)/\(size).png")) { phase in
      switch phase {
      case .empty:
        ProgressView()
      case .success(let image):
        image.resizable()
          .scaledToFit()
          .clipShape(Circle())
      case .failure:
        Image(systemName: "person")
          .foregroundColor(.red)
      @unknown default:
        EmptyView()
      }
    }
  }
}

struct MemberAvatarView_Previews: PreviewProvider {
  static var previews: some View {
    MemberAvatarView(url: "https://via.placeholder.com/50")
  }
}
