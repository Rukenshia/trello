//
//  AddCommentView.swift
//  trello
//
//  Created by Jan Christophersen on 11.11.22.
//

import SwiftUI

struct AddCommentView: View {
  @Binding var card: Card
  let addComment: (String) -> Void
  
  @State private var text: String = ""
  
  var body: some View {
    VStack {
      ZStack {
        TextEditor(text: $text)
          .frame(height: 100)
        
        if text.isEmpty {
          Text("Type here to add a comment")
            .foregroundColor(Color("TwZinc300"))
        }
      }
      HStack {
        Spacer()
        Button(action: {
          self.addComment(self.text)
          self.text = ""
        }) {
          
        }
        .buttonStyle(FlatButton(icon: "plus", text: "Add comment"))
      }
      .padding(4)
    }
  }
}

struct AddCommentView_Previews: PreviewProvider {
  static var previews: some View {
    AddCommentView(card: .constant(Card(id: "id", name: "name")), addComment: { _ in })
  }
}
