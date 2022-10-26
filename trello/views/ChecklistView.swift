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
    
    @State var color: Color = Color("CardBg").opacity(0.8);
    
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
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Mark all as done")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(self.color)
                    .cornerRadius(4)
                }
                .buttonStyle(.plain)
                .onHover { hover in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        self.color = hover ? Color("CardBg") : Color("CardBg").opacity(0.8);
                        
                        if (hover) {
                            NSCursor.pointingHand.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
                }
            }
            Divider()
            ForEach($checklist.checkItems) { checkItem in
                ChecklistItemView(item: checkItem, cardId: $checklist.idCard)
                    .padding(.vertical, 1)
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