//
//  ContextMenuEditCardView.swift
//  trello
//
//  Created by Jan Christophersen on 08.11.22.
//

import SwiftUI

struct ContextMenuEditCardView: View {
    @EnvironmentObject var trelloApi: TrelloApi
    @Binding var card: Card
    @Binding var show: Bool
    
    @State private var newName: String = ""
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Card name")
                    .font(.subheadline)
                
                TextField("", text: $newName, onCommit: self.updateName)
                    .font(.title3)
                    .textFieldStyle(.roundedBorder)
            }
            
            HStack {
                Spacer()
                
                Button(action: self.updateName) {
                    Text("Save")
                }
                .buttonStyle(FlatButton())
                
                Spacer()
            }
        }
        .onAppear {
            newName = card.name
        }
    }
    
    private func updateName() {
        self.trelloApi.updateCard(cardId: card.id, name: self.newName, completion: { _ in
            self.show = false
        })
    }
}

struct ContextMenuEditCardView_Previews: PreviewProvider {
    static var previews: some View {
        ContextMenuEditCardView(card: .constant(Card(id: "id", name: "name")), show: .constant(true))
    }
}
