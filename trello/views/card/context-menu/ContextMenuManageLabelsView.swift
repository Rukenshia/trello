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
    VStack(alignment: .leading, spacing: 8) {
      TextField("", text: $filter, onCommit: {
        // Take the first label that we can find?
      })
      ScrollView {
        Text("applied")
          .font(.headline)
          .frame(maxWidth: .infinity, alignment: .leading)
        ForEach(self.$labels.filter{ label in
          (self.filter.isEmpty || label.name.wrappedValue.lowercased().contains(self.filter.lowercased()))
          && self.card.idLabels.contains(label.id)
          
        }, id: \.id) { label in
          ContextMenuLabelView(label: label, card: $card, applied: true)
            .padding(.horizontal, 4)
        }
        
        Text("available")
          .font(.headline)
          .frame(maxWidth: .infinity, alignment: .leading)
        ForEach(self.$labels.filter{ label in
          (self.filter.isEmpty || label.name.wrappedValue.contains(self.filter))
          && !self.card.idLabels.contains(label.id)
          
        }, id: \.id) { label in
          ContextMenuLabelView(label: label, card: $card, applied: false)
            .padding(.horizontal, 4)
        }
      }
      .frame(minHeight: 200, maxHeight: 300)
    }.padding(8)
      .frame(minWidth: 100)
  }
}

struct ContextMenuManageLabelsView_Previews: PreviewProvider {
  static var previews: some View {
    ContextMenuManageLabelsView(labels: .constant([]), card: .constant(Card(id: "card", name: "a card")))
  }
}
