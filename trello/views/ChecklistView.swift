//
//  ChecklistView.swift
//  trello
//
//  Created by Jan Christophersen on 17.10.22.
//

import SwiftUI

struct ChecklistView: View {
    @Binding var checklist: Checklist;
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(checklist.name)
                .font(.title3)
            Divider()
            ForEach($checklist.checkItems) { checkItem in
                HStack {
                    Image(systemName: checkItem.wrappedValue.state == CheckItemState.complete ? "checkmark.circle" : "circle")
                    Text(checkItem.wrappedValue.name)
                    Spacer()
                }
            }
        }
        .padding(8)
    }
}

struct ChecklistView_Previews: PreviewProvider {
    static var previews: some View {
        ChecklistView(checklist: .constant(Checklist(id: "check1", idCard: "card1", name: "Checklist", checkItems: [CheckItem(id: "c1", idChecklist: "check1", name: "CheckItem1", state: CheckItemState.complete), CheckItem(id: "c2", idChecklist: "check1", name: "CheckItem2", state: CheckItemState.incomplete)])))
    }
}
