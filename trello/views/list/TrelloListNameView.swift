//
//  TrelloListNameView.swift
//  trello
//
//  Created by Jan Christophersen on 31.10.22.
//

import SwiftUI

struct TrelloListNameView: View {
  @EnvironmentObject var boardVm: BoardState
  let listId: String
  let name: String
  
  @FocusState private var focusedField: String?
  @State var editing: Bool = false
  @State var newName: String = ""
  @State var hovering: Bool = false
  
  var body: some View {
    HStack {
      HStack {
        if self.editing {
          Button(action: self.updateName) {
            
          }
          .buttonStyle(IconButton(icon: "checkmark", size: 16))
          TextField("List name", text: $newName, onCommit: self.updateName)
            .textFieldStyle(.plain)
            .focused($focusedField, equals: "name")
        } else {
          HStack {
            Text(name)
            if self.hovering {
              Button(action: {
                self.editing = true
                self.focusedField = "name"
                self.newName = name
              }) {
              }
              .buttonStyle(IconButton(icon: "square.and.pencil", size: 16, color: .clear, hoverColor: .clear, padding: 0))
            }
          }
          .onHover { hover in
            self.hovering = hover
          }
          .padding(.horizontal, 4)
          .padding(.vertical, 4)
          .background(self.hovering ? Color("TwZinc600") : .clear)
          .cornerRadius(4)
        }
        Spacer()
      }
      .lineLimit(1)
      .font(.title3)
      .multilineTextAlignment(.leading)
      .padding(.horizontal, 8)
      Spacer()
    }
  }
  
  private func updateName() {
    self.editing = false
    
    boardVm.setListName(listId: self.listId, name: self.newName)
  }
}

struct TrelloListNameView_Previews: PreviewProvider {
  static var previews: some View {
    TrelloListNameView(listId: "id", name: "card name")
  }
}
