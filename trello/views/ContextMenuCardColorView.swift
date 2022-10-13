//
//  ContextMenuCardColorView.swift
//  trello
//
//  Created by Jan Christophersen on 09.10.22.
//

import SwiftUI

struct ContextMenuCardColorView: View {
    @EnvironmentObject var trelloApi: TrelloApi;
    @Binding var labels: [Label];
    @Binding var card: Card;
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(minimum: 64)), GridItem(.flexible(minimum: 64))], spacing: 8) {
            ForEach($labels.filter{ label in label.wrappedValue.name.contains("color:") }) { label in
                Button(action: {
                    for removeLabel in self.labels.filter({ l in l.name.contains("color:") && l.name != label.wrappedValue.name }) {
                        self.trelloApi.removeLabelFromCard(card: self.card, labelId: removeLabel.id, completion: { newCard in
                            print("label removed")
                        })
                    }
                    self.trelloApi.addLabelToCard(card: self.card, labelId: label.wrappedValue.id, completion: { newCard in
                        print("label added")
                    })
                }) {
                    Text("click me")
                        .frame(width: 64, height: 48)
                }
                .buttonStyle(.plain)
                .background(Color("CardBg_\(label.wrappedValue.name.split(separator: ":")[1])"))
                .cornerRadius(4)
            }
        }
        .padding(16)
    }
}

struct ContextMenuCardColorView_Previews: PreviewProvider {
    static var previews: some View {
        ContextMenuCardColorView( labels: .constant([Label(id: "amber", name: "color:amber"), Label(id: "emerald", name: "color:emerald"), Label(id: "slate", name: "color:slate"), Label(id: "pink", name: "color:pink")]), card: .constant(Card(id: "cardid", name: "card")))
    }
}
