//
//  ContextMenuManageLabelsView.swift
//  trello
//
//  Created by Jan Christophersen on 09.10.22.
//

import SwiftUI

struct ContextMenuManageLabelsView: View {
    @Binding var labels: [Label];
    @Binding var card: Card;
    
    @State var filter: String = "";
    
    var body: some View {
        VStack(spacing: 8) {
            TextField(text: $filter) {
                
            }
            ScrollView {
                Text("applied")
                    .bold()
                ForEach(self.$labels.filter{ label in
                    (self.filter.isEmpty || label.name.wrappedValue.contains(self.filter))
                    && self.card.idLabels.contains(label.id)
                    
                }, id: \.id) { label in
                    ContextMenuLabelView(label: label, card: $card, applied: true)
                }
                
                Text("available")
                    .bold()
                ForEach(self.$labels.filter{ label in
                    (self.filter.isEmpty || label.name.wrappedValue.contains(self.filter))
                    && !self.card.idLabels.contains(label.id)
                    
                }, id: \.id) { label in
                    ContextMenuLabelView(label: label, card: $card, applied: false)
                }
            }
            .frame(maxHeight: 300)
        }.padding(8)
            .frame(minWidth: 100)
    }
}

struct ContextMenuManageLabelsView_Previews: PreviewProvider {
    static var previews: some View {
        ContextMenuManageLabelsView(labels: .constant([]), card: .constant(Card(id: "card", name: "a card")))
    }
}
