//
//  AddCardView.swift
//  trello
//
//  Created by Jan Christophersen on 10.10.22.
//

import SwiftUI

struct AddCardView: View {
    @EnvironmentObject var trelloApi: TrelloApi;
    @Binding var list: List;
    @Binding var showAddCard: Bool;
    
    @State private var name: String = "";
    @State private var description: String = "";
    
    var body: some View {
        VStack {
            HStack {
                Text("Add card")
                    .font(.title)
                Spacer()
                Button(action: {
                    showAddCard = false;
                }) {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .imageScale(.large)
                    }
                }
                .keyboardShortcut(.cancelAction)
                .buttonStyle(PlainButtonStyle())
            }
            HStack {
                Text("Card name:")
                TextField(text: self.$name) {
                    
                }
            }
            HStack(alignment: .top) {
                Text("Description:")
                TextEditor(text: self.$description)
            }
            HStack(alignment: .top) {
                Text("List:")
                Text(self.list.name)
            }
            Button(action: {
                self.trelloApi.createCard(list: self.list, name: self.name, description: self.description) { card in
                    print("card \(card.name) created")
                    
                    self.showAddCard = false
                }
            }) {
                Text("Create")
            }
        }
        .padding(8)
        .frame(minWidth: 400, minHeight: 400)
    }
}

struct AddCardView_Previews: PreviewProvider {
    static var previews: some View {
        AddCardView(list: .constant(List(id: "id", name: "list name")), showAddCard: .constant(true))
    }
}
