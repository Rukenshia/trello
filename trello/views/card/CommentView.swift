//
//  CommentView.swift
//  trello
//
//  Created by Jan Christophersen on 11.11.22.
//

import SwiftUI
import MarkdownUI

struct CommentView: View {
  @Binding var comment: ActionCommentCard
  
  var avatar: AnyView {
    return AnyView(AsyncImage(url: URL(string: "\(self.comment.memberCreator.avatarUrl)/50.png")) { phase in
      switch phase {
      case .empty:
        Circle()
          .fill(Color("TwZinc300"))
          .overlay {
            Text(comment.memberCreator.initials)
              .font(.system(size: 16))
              .foregroundColor(Color("TwZinc800"))
          }
      case .success(let image):
        image.resizable()
      case .failure:
        Circle()
          .fill(Color("TwRed900"))
      @unknown default:
        EmptyView()
      }
    })
  }
  
  var body: some View {
    VStack {
      HStack {
        ZStack {
          self.avatar
            .frame(width: 36, height: 36)
            .clipShape(Circle())
        }
        .padding(6)
        HStack {
          Markdown(comment.data.text)
          Spacer()
        }
        .padding()
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(Color("TwZinc600"), lineWidth: 1)
        )
      }
      HStack {
        Spacer()
        Text(TrelloApi.DateFormatter.date(from: comment.date)!.formatted())
          .font(.footnote)
          .foregroundColor(Color("TwZinc300"))
      }
    }
  }
}

struct CommentView_Previews: PreviewProvider {
  static var previews: some View {
    CommentView(comment: .constant(ActionCommentCard(id: "id", idMemberCreator: "member-id", type: .commentCard, data: ActionDataCommentCard(text: "comment text"), memberCreator: Member(id: "member-id", username: "member-username", avatarUrl: "https://trello-members.s3.amazonaws.com/5e4919458e3371666e3be20c/f30eb004ca0926ea216e7dc32e00ead1", fullName: "member full name", initials: "MF"), date: TrelloApi.DateFormatter.string(from: Date.now))))
  }
}