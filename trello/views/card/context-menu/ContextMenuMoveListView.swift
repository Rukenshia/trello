//
//  ContextMenuMoveListView.swift
//  trello
//
//  Created by Jan Christophersen on 09.10.22.
//

import SwiftUI

struct ContextMenuMoveListView: View {
    @EnvironmentObject var trelloApi: TrelloApi;
    @Binding var list: List;
    @Binding var card: Card;
    
    @State var color: Color = Color(.clear);
    
    var body: some View {
        Button(action: {
            self.trelloApi.moveCard(cardId: card.id, destination: list.id) { newCard in
                trelloApi.objectWillChange.send()
//                self.card = newCard
            }
        }) {
            HStack {
                Text(list.name)
                Spacer()
                
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(self.color)
            .cornerRadius(4)
        }
        .onHover { hovering in
            if hovering {
                self.color = Color("CardBg");
                return;
            }
            
            self.color = Color(.clear);
        }
        .buttonStyle(.plain)
    }
}

struct ContextMenuMoveListView_Previews: PreviewProvider {
    static var previews: some View {
        ContextMenuMoveListView(list: .constant(List(id: "id", name: "name")), card: .constant(Card(id: "cardid", name: "card")))
    }
}
