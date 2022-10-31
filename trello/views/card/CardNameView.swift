//
//  CardNameView.swift
//  trello
//
//  Created by Jan Christophersen on 31.10.22.
//

import SwiftUI

struct CardNameView: View {
    @EnvironmentObject var trelloApi: TrelloApi
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
                    .buttonStyle(IconButton(icon: "square.and.pencil", size: 16))
                    Text(card.name)
                }
                Spacer()
            }
            .font(.title)
            Spacer()
        }
    }
    
    private func updateName() {
        self.editing = false
        
        self.trelloApi.setCardName(card: self.card, name: self.newName) { newCard in
            
        }
    }
}

struct CardNameView_Previews: PreviewProvider {
    static var previews: some View {
        CardNameView(card: .constant(Card(id: "id", name: "card name")))
    }
}
