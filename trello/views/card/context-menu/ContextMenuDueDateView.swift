//
//  ContextMenuDueDateView.swift
//  trello
//
//  Created by Jan Christophersen on 10.10.22.
//

import SwiftUI

struct ContextMenuDueDateView: View {
    @EnvironmentObject var trelloApi: TrelloApi;
    @Binding var card: Card;
    
    @State private var date: Date = Date.now;
    
    var body: some View {
        VStack {
            DatePicker("", selection: $date, displayedComponents: [.date]).datePickerStyle(.graphical)
            DatePicker("", selection: $date, displayedComponents: [.hourAndMinute]).datePickerStyle(.stepperField)
            HStack {
                if card.due != nil {
                    Button(action: {
                        self.trelloApi.removeCardDue(cardId: card.id, completion: { card in
                            print("\(card.name): due updated to \(TrelloApi.DateFormatter.string(from: self.date))")
                        })
                    }) {
                        Text("Remove Due")
                    }
                    .buttonStyle(FlatButton(icon: "trash"))
                }
                
                Spacer()
                
                Button(action: {
                    self.trelloApi.updateCard(cardId: card.id, due: self.date, completion: { card in
                        print("\(card.name): due updated to \(TrelloApi.DateFormatter.string(from: self.date))")
                    })
                }) {
                    Text("Save")
                }
                .buttonStyle(FlatButton())
            }
        }
        .onAppear {
            if let due = self.card.dueDate {
                self.date = due
            }
        }
        .padding()
    }
}

struct ContextMenuDueDateView_Previews: PreviewProvider {
    static var previews: some View {
        ContextMenuDueDateView(card: .constant(Card(id: "id", name: "card name", due: "2022-10-10T07:25:24.331Z")))
    }
}
