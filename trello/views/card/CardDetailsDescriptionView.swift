//
//  CardDetailsDescriptionView.swift
//  trello
//
//  Created by Jan Christophersen on 01.11.22.
//

import SwiftUI
import MarkdownUI

struct CardDetailsDescriptionView: View {
    @EnvironmentObject var trelloApi: TrelloApi
    @Binding var card: Card
    
    @State private var desc: String = ""
    @State private var editing: Bool = false
    @State private var hovering: Bool = false
    
    var body: some View {
        if self.editing {
            TextEditor(text: $desc)
            
            Button(action: {
                self.editing = false;
                
                self.trelloApi.updateCard(cardId: card.id, desc: self.desc, completion: { newCard in
                    print("description updated")
                })
            }) {
                Text("Save changes")
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color("TwZinc700"))
                    .cornerRadius(4)
            }
            .buttonStyle(.plain)
        } else {
            if !self.card.desc.isEmpty {
                Markdown(self.card.desc)
                    .colorInvert()
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(Color("TwZinc200"))
                    .foregroundColor(Color("TwStone900"))
                    .cornerRadius(4)
            }
            
            Button(action: self.startEditing) {
            }
            .buttonStyle(FlatButton(icon: "pencil", text:" Edit"))
            
        }
    }
    
    private func startEditing() {
        self.editing = true
        self.desc = self.card.desc
    }
}

struct CardDetailsDescriptionView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailsDescriptionView(card: .constant(Card(id: "id", name: "name")))
    }
}
