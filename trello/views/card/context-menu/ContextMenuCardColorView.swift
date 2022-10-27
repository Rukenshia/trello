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
    @Binding var show: Bool;
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(minimum: 64)), GridItem(.flexible(minimum: 64))], spacing: 8) {
            ForEach($labels.filter{ label in label.wrappedValue.name.contains("color:") }) { label in
                CardColorView(card: $card, label: label, labels: $labels, show: $show)
            }
        }
        .padding(16)
    }
}

struct ContextMenuCardColorView_Previews: PreviewProvider {
    static var previews: some View {
        ContextMenuCardColorView( labels: .constant([Label(id: "amber", name: "color:amber"), Label(id: "emerald", name: "color:emerald"), Label(id: "slate", name: "color:slate"), Label(id: "pink", name: "color:pink")]), card: .constant(Card(id: "cardid", name: "card")), show: .constant(true))
    }
}
