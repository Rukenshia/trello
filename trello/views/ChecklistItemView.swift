//
//  ChecklistItemView.swift
//  trello
//
//  Created by Jan Christophersen on 17.10.22.
//

import SwiftUI

struct ChecklistItemView: View {
    @EnvironmentObject var trelloApi: TrelloApi;
    
    @Binding var item: CheckItem;
    @Binding var cardId: String;
    
    @State var color: Color = Color.secondary;
    
    var body: some View {
        HStack {
            Button(action: {
                if item.state == .incomplete {
                    item.state = .complete
                } else {
                    item.state = .incomplete
                }
                
                trelloApi.updateCheckItem(cardId: cardId, checkItem: item, completion: { checkItem in
                    
                })
            }) {
                Image(systemName: item.state == CheckItemState.complete ? "checkmark.circle" : "circle")
                    .foregroundColor(self.color)
            }
            .buttonStyle(.plain)
            .onHover { hover in
                if hover {
                    self.color = Color.accentColor
                } else {
                    self.color = Color.secondary
                }
            }
            Text(item.name)
                .foregroundColor(item.state == .complete ? .secondary : .primary)
            Spacer()
        }
    }
}

struct ChecklistItemView_Previews: PreviewProvider {
    static var previews: some View {
        ChecklistItemView(item: .constant(CheckItem(id: "id", idChecklist: "idc", name: "checklist item", state: .complete)), cardId: .constant("cardId"))
    }
}
