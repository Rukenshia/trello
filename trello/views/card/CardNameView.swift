//
//  CardNameView.swift
//  trello
//
//  Created by Jan Christophersen on 31.10.22.
//

import SwiftUI

struct CardNameView: View {
  @EnvironmentObject var boardVm: BoardState
  @Binding var card: Card
  
  @FocusState private var focusedField: String?
  @State var editing: Bool = false
  @State var newName: String = ""
  
  var body: some View {
    HStack {
      HStack {
        if self.editing {
          Button(action: self.updateName) {
            
          }
          .buttonStyle(IconButton(icon: "checkmark", size: 16))
          TextField("Card name", text: $newName, onCommit: self.updateName)
            .textFieldStyle(.plain)
            .focused($focusedField, equals: "name")
        } else {
          Button(action: {
            self.editing = true
            self.focusedField = "name"
            self.newName = card.name
          }) {
            
          }
          .buttonStyle(IconButton(icon: "square.and.pencil", size: 16, color: .clear, hoverColor: .clear))
          Text(card.name)
          
        }
        Spacer()
      }
      .onTapGesture {
        if !editing {
          editing = true
          self.newName = card.name
          self.focusedField = "name"
        }
      }
      .font(.title)
      Spacer()
    }
  }
  
  private func updateName() {
    self.editing = false
    
    boardVm.updateCard(cardId: self.card.id, name: self.newName)
  }
}

struct CardNameView_Previews: PreviewProvider {
  static var previews: some View {
    CardNameView(card: .constant(Card(id: "id", name: "card name")))
  }
}
