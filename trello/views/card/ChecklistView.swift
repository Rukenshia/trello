//
//  ChecklistView.swift
//  trello
//
//  Created by Jan Christophersen on 17.10.22.
//

import SwiftUI

struct ChecklistView: View {
    @EnvironmentObject var trelloApi: TrelloApi;
    @Binding var checklist: Checklist;
    var onDelete: () -> Void = {};
    
    @State var newChecklistItemName: String = "";
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(checklist.name)
                    .font(.title3)
                Spacer()
                Button(action: {
                    for var item in self.checklist.checkItems {
                        item.state = .complete
                        trelloApi.updateCheckItem(cardId: self.checklist.idCard, checkItem: item) { checkItem in
                            if let index = self.checklist.checkItems.firstIndex(where: { ci in ci.id == checkItem.id }) {
                                self.checklist.checkItems[index] = checkItem
                            }
                        }
                    }
                }) {
                }
                .buttonStyle(FlatButton(icon: "checkmark.circle.fill", text: "Mark all as done"))
                Button(action: {
                    self.trelloApi.deleteChecklist(checklistId: self.checklist.id) {
                        self.onDelete()
                    }
                }) {
                }
                .buttonStyle(FlatButton(icon: "trash"))
            }
            Divider()
            ForEach($checklist.checkItems) { checkItem in
                ChecklistItemView(cardId: $checklist.idCard, checklistId: self.$checklist.id, item: checkItem)
                    .padding(.vertical, 1)
            }
            HStack {
                Image(systemName: "circle")
                    .foregroundColor(.secondary)
                TextField("Type and press return to add a new checklist item", text: self.$newChecklistItemName, onCommit: {
                    self.trelloApi.addCheckItem(checklistId: self.checklist.id, name: self.newChecklistItemName) { checkItem in
                        self.checklist.checkItems.append(checkItem)
                        self.newChecklistItemName = ""
                    }
                })
                    .textFieldStyle(.plain)
                
            }.padding(.top, 2)
        }
        .padding(8)
    }
}

struct ChecklistView_Previews: PreviewProvider {
    static var previews: some View {
        ChecklistView(checklist: .constant(Checklist(id: "check1", idCard: "card1", name: "Checklist", checkItems: [CheckItem(id: "c1", idChecklist: "check1", name: "CheckItem1", state: CheckItemState.complete), CheckItem(id: "c2", idChecklist: "check1", name: "CheckItem2", state: CheckItemState.incomplete)])))
    }
}
